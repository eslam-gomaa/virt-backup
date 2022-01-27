#!/bin/bash -e
apt install -y qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils virtinst libvirt-daemon
apt install -y git

systemctl start libvirtd
systemctl enable libvirtd
systemctl is-active libvirtd

virsh net-start default
virsh net-autostart default