#!/usr/bin/env bash
#
# clone-vm.sh - Interactive KVM VM cloning and network configuration script.
#
# Clones an existing KVM VM N times, assigns sequential hostnames, and injects
# a static IP configuration into each clone via virt-sysprep. Works with
# Ubuntu/Debian (Netplan) and RHEL/Rocky/Fedora (NetworkManager keyfiles).

set -euo pipefail

# --- Defaults / constants ------------------------------------------------------

VM_USER="milad"
VM_PASSWORD="123"
LIBVIRT_IMG_DIR="/var/lib/libvirt/images"

# --- Helpers -------------------------------------------------------------------

err()  { echo "ERROR: $*" >&2; }
info() { echo "[*] $*"; }
ok()   { echo "[+] $*"; }

require_root() {
  if [[ $EUID -ne 0 ]]; then
    err "This script must be run as root (use sudo)."
    exit 1
  fi
}

require_cmd() {
  local cmd=$1
  if ! command -v "$cmd" >/dev/null 2>&1; then
    err "Required command not found: $cmd"
    exit 1
  fi
}

prompt() {
  # prompt <var> <message> [default]
  local var=$1 msg=$2 default=${3:-}
  local input
  if [[ -n $default ]]; then
    read -r -p "$msg [$default]: " input
    input=${input:-$default}
  else
    read -r -p "$msg: " input
  fi
  printf -v "$var" '%s' "$input"
}

valid_ipv4() {
  local ip=$1
  [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] || return 1
  local IFS=.
  local -a o=($ip)
  for n in "${o[@]}"; do
    (( n >= 0 && n <= 255 )) || return 1
  done
  return 0
}

increment_ip() {
  # increment_ip <base_ip> <offset> -> echoes the resulting IPv4
  local ip=$1 offset=$2
  local IFS=.
  local -a o=($ip)
  local last=$(( o[3] + offset ))
  if (( last > 254 )); then
    err "Incrementing $ip by $offset overflows the last octet."
    exit 1
  fi
  echo "${o[0]}.${o[1]}.${o[2]}.$last"
}

# --- Pre-flight ----------------------------------------------------------------

require_root
for c in virsh virt-clone virt-sysprep; do require_cmd "$c"; done

# --- Collect inputs ------------------------------------------------------------

echo "==============================================="
echo "  KVM Clone & Network Configuration Wizard"
echo "==============================================="

prompt SOURCE_VM   "Source VM name (existing KVM domain)"
prompt CLONE_COUNT "Number of clones to create" "3"
prompt BASE_NAME   "Base name prefix (e.g. SRV)" "srv"
prompt START_IP    "Starting IP address" "192.168.122.11"
prompt CIDR        "Subnet CIDR prefix (e.g. 24)" "24"
prompt GATEWAY     "Default gateway IP" "192.168.122.1"
prompt DNS_SERVER  "Preferred DNS server IP" "8.8.8.8"

# Normalize / validate
BASE_NAME=${BASE_NAME,,}                    # lowercase
CIDR=${CIDR#/}                              # strip leading "/"

if ! virsh dominfo "$SOURCE_VM" >/dev/null 2>&1; then
  err "Source VM '$SOURCE_VM' does not exist in libvirt."
  exit 1
fi

if [[ $(virsh domstate "$SOURCE_VM") != "shut off" ]]; then
  err "Source VM '$SOURCE_VM' must be shut off before cloning."
  err "Run: virsh shutdown $SOURCE_VM"
  exit 1
fi

[[ $CLONE_COUNT =~ ^[1-9][0-9]*$ ]] || { err "Clone count must be a positive integer."; exit 1; }
valid_ipv4 "$START_IP"   || { err "Invalid starting IP: $START_IP"; exit 1; }
valid_ipv4 "$GATEWAY"    || { err "Invalid gateway: $GATEWAY"; exit 1; }
valid_ipv4 "$DNS_SERVER" || { err "Invalid DNS server: $DNS_SERVER"; exit 1; }
[[ $CIDR =~ ^[0-9]+$ && $CIDR -ge 1 && $CIDR -le 32 ]] || { err "Invalid CIDR: /$CIDR"; exit 1; }

# --- Summary & confirm ---------------------------------------------------------

echo
echo "------------------- SUMMARY -------------------"
printf "  Source VM      : %s\n" "$SOURCE_VM"
printf "  Clone count    : %s\n" "$CLONE_COUNT"
printf "  Base name      : %s\n" "$BASE_NAME"
printf "  Guest user     : %s\n" "$VM_USER"
echo   "  Planned clones :"
for ((i=1; i<=CLONE_COUNT; i++)); do
  ip=$(increment_ip "$START_IP" $((i-1)))
  printf "    - %s-%d  ->  %s/%s\n" "$BASE_NAME" "$i" "$ip" "$CIDR"
done
printf "  Gateway        : %s\n" "$GATEWAY"
printf "  DNS server     : %s\n" "$DNS_SERVER"
echo "-----------------------------------------------"
echo

read -r -p "Proceed with cloning? (y/N): " confirm
case "${confirm,,}" in
  y|yes) ;;
  *) info "Aborted by user."; exit 0 ;;
esac

# --- Clone & customize ---------------------------------------------------------

# Build a small inline script we'll run inside each guest via virt-sysprep
# --firstboot. It detects the renderer and writes the correct config.
make_firstboot_script() {
  local hostname=$1 ip=$2 cidr=$3 gw=$4 dns=$5
  cat <<EOF
#!/bin/bash
set -e

# Set hostname
hostnamectl set-hostname "$hostname" || hostname "$hostname"
echo "$hostname" > /etc/hostname

# Update /etc/hosts
if grep -qE '^127\.0\.1\.1' /etc/hosts; then
  sed -i "s/^127\.0\.1\.1.*/127.0.1.1\t$hostname/" /etc/hosts
else
  echo "127.0.1.1 $hostname" >> /etc/hosts
fi

# Pick the first non-loopback interface
IFACE=\$(ip -o link show | awk -F': ' '!/lo:/ {print \$2; exit}')
if [[ -z "\$IFACE" ]]; then
  echo "No network interface found" >&2
  exit 1
fi

if [[ -d /etc/netplan ]]; then
  # Ubuntu / Debian — Netplan
  rm -f /etc/netplan/*.yaml
  cat > /etc/netplan/01-static.yaml <<NETPLAN
network:
  version: 2
  renderer: networkd
  ethernets:
    \$IFACE:
      dhcp4: no
      addresses: [$ip/$cidr]
      routes:
        - to: default
          via: $gw
      nameservers:
        addresses: [$dns]
NETPLAN
  chmod 600 /etc/netplan/01-static.yaml
  netplan apply || true

elif command -v nmcli >/dev/null 2>&1; then
  # RHEL / Rocky / Fedora — NetworkManager
  CON=\$(nmcli -t -f NAME,DEVICE con show --active | awk -F: -v d="\$IFACE" '\$2==d {print \$1; exit}')
  CON=\${CON:-\$IFACE}
  nmcli con mod "\$CON" ipv4.addresses "$ip/$cidr" ipv4.gateway "$gw" \\
                       ipv4.dns "$dns" ipv4.method manual || \\
  nmcli con add type ethernet ifname "\$IFACE" con-name "\$CON" \\
                       ipv4.addresses "$ip/$cidr" ipv4.gateway "$gw" \\
                       ipv4.dns "$dns" ipv4.method manual
  nmcli con up "\$CON" || true

elif [[ -d /etc/sysconfig/network-scripts ]]; then
  # Legacy ifcfg
  cat > /etc/sysconfig/network-scripts/ifcfg-\$IFACE <<IFCFG
DEVICE=\$IFACE
BOOTPROTO=none
ONBOOT=yes
IPADDR=$ip
PREFIX=$cidr
GATEWAY=$gw
DNS1=$dns
IFCFG
  systemctl restart network || systemctl restart NetworkManager || true
else
  echo "No supported network configuration system found" >&2
  exit 1
fi

# Ensure the SSH server is installed, has host keys, and is running.
# virt-sysprep's default "ssh-hostkeys" operation strips host keys from the
# clone, and cloned images sometimes lack openssh-server entirely, so sshd
# fails to start unless we repair this on first boot.
if command -v apt-get >/dev/null 2>&1; then
  dpkg -s openssh-server >/dev/null 2>&1 || apt-get update -y && apt-get install -y openssh-server || true
elif command -v dnf >/dev/null 2>&1; then
  rpm -q openssh-server >/dev/null 2>&1 || dnf install -y openssh-server || true
elif command -v yum >/dev/null 2>&1; then
  rpm -q openssh-server >/dev/null 2>&1 || yum install -y openssh-server || true
fi

ssh-keygen -A || true

systemctl enable --now ssh 2>/dev/null || systemctl enable --now sshd 2>/dev/null || true
systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null || true
EOF
}

for ((i=1; i<=CLONE_COUNT; i++)); do
  CLONE_NAME="${BASE_NAME}-${i}"
  CLONE_IP=$(increment_ip "$START_IP" $((i-1)))
  CLONE_DISK="${LIBVIRT_IMG_DIR}/${CLONE_NAME}.qcow2"

  info "Cloning $SOURCE_VM -> $CLONE_NAME ($CLONE_IP/$CIDR)"

  if virsh dominfo "$CLONE_NAME" >/dev/null 2>&1; then
    err "Domain '$CLONE_NAME' already exists. Skipping."
    continue
  fi

  virt-clone \
    --original "$SOURCE_VM" \
    --name "$CLONE_NAME" \
    --file "$CLONE_DISK"

  firstboot_script=$(mktemp --suffix=.sh)
  make_firstboot_script "$CLONE_NAME" "$CLONE_IP" "$CIDR" "$GATEWAY" "$DNS_SERVER" > "$firstboot_script"
  chmod +x "$firstboot_script"

  info "Injecting hostname, network config, and credentials into $CLONE_NAME"
  virt-sysprep \
    --domain "$CLONE_NAME" \
    --hostname "$CLONE_NAME" \
    --password "${VM_USER}:password:${VM_PASSWORD}" \
    --operations defaults,-ssh-userdir \
    --firstboot "$firstboot_script"

  rm -f "$firstboot_script"

  info "Starting $CLONE_NAME"
  virsh start "$CLONE_NAME" >/dev/null

  ok "$CLONE_NAME ready at $CLONE_IP/$CIDR"
done

echo
ok "All $CLONE_COUNT clone(s) created successfully."
echo "Run 'virsh list --all' to verify."
