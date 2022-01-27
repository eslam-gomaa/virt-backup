#!/bin/bash -e

dnf module install virt -y
dnf install -y virt-install virt-viewer libguestfs-tools
dnf install -y git

systemctl enable libvirtd
systemctl start libvirtd
systemctl is-active libvirtd

