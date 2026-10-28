#! /usr/bin/env bash

set -uo pipefail

fail() {
  echo "ERROR: $1" >&2
  exit 1
}

ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/aarch64$/arm64/')"
OS="$(uname | tr '[:upper:]' '[:lower:]')"

# ---------------------------------------------------------------------------
# Ansible
# ---------------------------------------------------------------------------
sudo apt update && sudo apt install -y ansible \
  || fail "Ansible packages failed to install"

# ---------------------------------------------------------------------------
# Terraform
# ---------------------------------------------------------------------------
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common curl wget git \
  || fail "Terraform prerequisites failed to install"

wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update && sudo apt install -y terraform \
  || fail "Terraform packages failed to install"
terraform -version || fail "Terraform is not working"

# ---------------------------------------------------------------------------
# kubectl
# ---------------------------------------------------------------------------
KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
curl -fsSLO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/${OS}/${ARCH}/kubectl" \
  || fail "kubectl download failed"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
  || fail "kubectl packages failed to install"
rm -f kubectl

# ---------------------------------------------------------------------------
# kubecolor (downloaded from GitHub releases)
# ---------------------------------------------------------------------------
KUBECOLOR_VERSION="$(curl -fsSL https://api.github.com/repos/kubecolor/kubecolor/releases/latest \
  | grep -Po '"tag_name": *"v\K[^"]+')"
TMP_DIR="$(mktemp -d)"
curl -fsSL "https://github.com/kubecolor/kubecolor/releases/download/v${KUBECOLOR_VERSION}/kubecolor_${KUBECOLOR_VERSION}_${OS}_${ARCH}.tar.gz" \
  | tar -xz -C "${TMP_DIR}" \
  || fail "kubecolor download failed"
sudo install -o root -g root -m 0755 "${TMP_DIR}/kubecolor" /usr/local/bin/kubecolor \
  || fail "kubecolor failed to install"
rm -rf "${TMP_DIR}"

# ---------------------------------------------------------------------------
# krew (kubectl plugin manager)
# ---------------------------------------------------------------------------
(
  set -e
  cd "$(mktemp -d)"
  KREW="krew-${OS}_${ARCH}"
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
  tar zxf "${KREW}.tar.gz"
  ./"${KREW}" install krew
) || fail "krew failed to install"

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Persist krew PATH for bash and zsh (only once)
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [[ -f "$rc" ]] || continue
  grep -q '.krew/bin' "$rc" || \
    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> "$rc"
done

# ---------------------------------------------------------------------------
# kubectl plugins via krew
# ---------------------------------------------------------------------------
KREW_PLUGINS=(
  ctx               # switch contexts:      kubectl ctx
  ns                # switch namespaces:    kubectl ns
  neat              # clean YAML output:    kubectl get pod x -o yaml | kubectl neat
  tree              # ownership tree:       kubectl tree deploy x
  stern             # multi-pod log tail:   kubectl stern app
  view-secret       # decode secrets:       kubectl view-secret mysecret
  who-can           # RBAC lookup:          kubectl who-can get pods
  access-matrix     # RBAC matrix:          kubectl access-matrix
  resource-capacity # node req/limits:      kubectl resource-capacity
  df-pv             # PV disk usage:        kubectl df-pv
  images            # list images in use:   kubectl images
  node-shell        # shell on a node:      kubectl node-shell <node>
  explore           # fuzzy explain:        kubectl explore
)

kubectl krew update || fail "krew index update failed"
for plugin in "${KREW_PLUGINS[@]}"; do
  kubectl krew install "${plugin}" || echo "WARNING: krew plugin '${plugin}' failed to install" >&2
done

# ---------------------------------------------------------------------------
# Helm
# ---------------------------------------------------------------------------
curl -fsSL -o get_helm.sh \
  https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
  || fail "helm installer download failed"
chmod 700 get_helm.sh
./get_helm.sh || fail "helm packages failed to install"
rm -f get_helm.sh

# Shell completions
sudo mkdir -p /etc/bash_completion.d
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
helm completion bash    | sudo tee /etc/bash_completion.d/helm    > /dev/null

mkdir -p "$HOME/.zsh/completions"
kubectl completion zsh > "$HOME/.zsh/completions/_kubectl"
helm completion zsh    > "$HOME/.zsh/completions/_helm"
# For zsh, make sure ~/.zshrc has, before compinit:
#   fpath=($HOME/.zsh/completions $fpath)

echo "Done. Restart your shell (or 'source ~/.bashrc') to use krew plugins."
echo "Installed plugins:"
kubectl krew list
