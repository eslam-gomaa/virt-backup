

### Create & Restore snapshots

* The following commands are tested to [ `create` --> `delete` then `restore` ] KVM snapshots

```bash
# Create snapshot
virsh snapshot-create-as --domain mv12 --name 'snap 26'

# export snapshot xml
virsh snapshot-dumpxml mv12 'snap 26'  > /tmp/snap-26.xml

# the snapshosts created with the 'snapshot-create-as' are created in a disk file 

qemu-img info /var/lib/libvirt/images/backup-2/mv12/mv12.snap\ 1
#mage: /var/lib/libvirt/images/backup-2/mv12/mv12.snap 1
#file format: qcow2
#virtual size: 1.0T (1076103217152 bytes)
#disk size: 4.8G
#cluster_size: 65536
#backing file: /var/lib/libvirt/images/backup-2/mv12/mv12.1581930918
#backing file format: qcow2
#Snapshot list:
#ID        TAG                 VM SIZE                DATE       VM CLOCK
#1         snap 2                 1.1G 2020-02-17 10:22:02   00:33:04.805
#2         snap 25                1.1G 2020-02-17 10:31:27   00:40:51.417
#3         snap 26                1.5G 2020-02-17 10:37:13   00:45:10.965


# Restore the snapshot
virsh snapshot-create --domain mv12 --xmlfile /tmp/snap-26.xml
```

