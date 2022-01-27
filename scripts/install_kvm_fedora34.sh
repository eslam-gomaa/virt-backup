#!/bin/bash -e

dnf -y install bridge-utils libvirt virt-install qemu-kvm
dnf install -y git

systemctl enable libvirtd
systemctl start libvirtd
systemctl is-active libvirtd