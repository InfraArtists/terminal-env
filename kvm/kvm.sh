#!/usr/bin/env bash

# check if server has support for KVM
if [[ $(egrep -c '(vmx|svm)' /proc/cpuinfo) -eq 0 ]]; then
  echo "KVM not supported"
  exit 1
fi
# install KVM
sudo  apt install cpu-checker
kvm-ok
sudo apt install -y qemu-kvm virt-manager libvirt-daemon-system virtinst \
  libvirt-clients bridge-utils
sudo systemctl enable --now libvirtd
sudo systemctl status libvirtd
sudo adduser $USER kvm
sudo adduser $USER libvirt

