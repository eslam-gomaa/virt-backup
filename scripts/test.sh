#!/bin/bash -e


echo """
**************************************
      Create a test VM
**************************************
"""

cd /var/lib/libvirt/images
wget -O cirros.img https://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img

virt-install \
    --virt-type=qemu \
    --name cirros \
    --os-variant=rhel7 \
    --ram 512 \
    --vcpus=1 \
    --disk /var/lib/libvirt/images/cirros.img,bus=virtio,format=qcow2 \
    --network bridge=virbr0,model=virtio \
    --noautoconsole \
    --import

echo """
**************************************
      Take snapshots
**************************************
"""
sleep 30
virsh snapshot-create-as --domain cirros --name test-running

virsh destroy cirros
sleep 5
virsh snapshot-create-as --domain cirros --name test-shutdown

virsh start cirros
sleep 30


echo """
**************************************
      Backup the VM
**************************************
"""
mkdir /var/lib/libvirt/images/backup/

ruby /var/virt-backup/virt-backup.rb --backup \
  --with-snapshots \
  --original-vm cirros \
  --save-dir /var/lib/libvirt/images/backup/


echo """
**************************************
      Delete Original VM
**************************************
"""

virsh snapshot-delete cirros --current
virsh snapshot-delete cirros --current
virsh destroy cirros
virsh undefine cirros
rm /var/lib/libvirt/images/cirros.img -rf



echo """
**************************************
      Restore the VM
**************************************
"""

ruby /var/virt-backup/virt-backup.rb --restore \
  --with-snapshots \
  --backup-file /var/lib/libvirt/images/backup/cirros.zip \
  --restore-dir /var/lib/libvirt/images/


echo """
**************************************
           End of tests
**************************************
"""

