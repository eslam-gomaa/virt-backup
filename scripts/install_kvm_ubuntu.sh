#!/bin/bash -e

apt update
apt install qemu-kvm libvirt-bin bridge-utils virtinst -y

systemctl start libvirtd
systemctl enable libvirtd
systemctl is-active libvirtd
