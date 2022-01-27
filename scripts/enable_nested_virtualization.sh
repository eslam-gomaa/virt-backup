#!/bin/bash -e

# https://docs.fedoraproject.org/en-US/quick-docs/using-nested-virtualization-in-kvm/

modprobe -r kvm_intel
modprobe kvm_intel nested=1

output=$(cat /sys/module/kvm_intel/parameters/nested)
if [[ $output  == "N" ]]
then
    echo "ERROR -- Failed to enable nested virtualization."
fi
