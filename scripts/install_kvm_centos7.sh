#!/bin/bash -e
yum install -y qemu-kvm qemu-img virt-manager libvirt libvirt-python 
yum install -y git

systemctl start libvirtd
systemctl enable libvirtd
systemctl is-active libvirtd

