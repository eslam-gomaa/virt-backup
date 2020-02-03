# virt-backup :rocket:
Fully backup & restore your KVM Virtual Machines 

---

## `virt-backup` Features:

* Ability to backup all the VM's disks or only system disk
* compress the backup *directly* in a ZIP file, which helps to decrease backup size
* validate the restore proces with the checksum of the original VM (taken on backup)
* Ability to backup and restore all the VM's snapshot

---

## Install

---

## Examples

* Backup a VM with all its disks

> `Note` To backup the `Snapshots` of the VM, use the option `--with-snapshots`

```bash
ruby virt-backup.rb --backup \
 --with-snapshots \
 --original-vm kubernetes-master \
 --save-dir /var/lib/libvirt/images/backup/
```

* Backup a VM with only system disk

```bash
ruby virt-backup.rb --backup \
 --with-snapshots \
 --original-vm kubernetes-master \
 --system-disk-only \
 --save-dir /var/lib/libvirt/images/backup/
```

* Restore a VM from backup

> `Note` no options needed when restoring a backup with only system disk, *the script detects and handles that.*

> `Note` To restore the `Snapshots` of the VM, use the option `--with-snapshots`

```bash
ruby virt-backup.rb --restore \
 --with-snapshots \
 --backup-file /var/lib/libvirt/images/backup/kubernetes-master.zip \
 --restore-dir /var/lib/libvirt/images/backup/
```

### Example screesh shoots

* Backup a VM
```bash
ruby virt-backup.rb --backup \
 --with-snapshots \
 --original-vm kubernetes-master \
 --save-dir /var/lib/libvirt/images/backup/
```

![](https://i.imgur.com/Y6XEYTI.png)

**Notice the difference in size**
> the VM's additional 3 disks were created for testing, but compressing `2.5G` to `692M` is not bad :full_moon_with_face

![](https://i.imgur.com/8amolTB.png)


* Delete the VM
```bash
virsh destroy kubernetes-master
virsh snapshot-list kubernetes-master
virsh snapshot-delete  kubernetes-master random
virsh snapshot-delete  kubernetes-master snapshot1
virsh snapshot-delete  kubernetes-master snapshot2
virsh undefine kubernetes-master

rm /var/lib/libvirt/images/kubernetes-master* -rf
```

![](https://i.imgur.com/i1zlitL.png)


* Restore the VM






