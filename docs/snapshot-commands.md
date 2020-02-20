

### Create & Restore snapshots

* The following commands are tested to [ `create` --> `move` --> `restore` ] KVM snapshots

* worked with copying the disk and create another VM from it, then restore the snapshots 


```bash
# Create snapshot
virsh snapshot-create-as --domain snap2 --name 'snap2-s2'

# Create snapshot (not sure if '--security-info' is necessary)
virsh snapshot-dumpxml snap1 snap2-s1 --security-info > snap2-s2.xml

## --> Need to modify (disk, name & id) info first

# Define the snapshot on the destination
virsh snapshot-create --domain snap22 /root/snap2-s2.xml --redefine

# Set the current snapshot
virsh snapshot-current snap22 --security-info --snapshotname snap2-s2
virsh snapshot-current snap2--name


# Forcibly revert a snapshot (In my case the mac address is different)
virsh snapshot-revert --domain snap22 --snapshotname snap2-s1 --force
```






