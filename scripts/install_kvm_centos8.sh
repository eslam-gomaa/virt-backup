#!/bin/bash -e

dnf module install virt
dnf install virt-install virt-viewer libguestfs-tools
dnf install -y git

systemctl enable libvirtd
systemctl start libvirtd
systemctl is-active libvirtd

