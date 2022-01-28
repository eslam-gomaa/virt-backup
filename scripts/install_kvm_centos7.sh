#!/bin/bash -e
yum install -y qemu-kvm qemu-img libvirt libvirt-python virt-install virt-viewer libguestfs-tools
yum install -y git

systemctl start libvirtd
systemctl enable libvirtd
systemctl is-active libvirtd

