# virt-backup
Fully backup & restore your KVM Virtual Machines

---

## `virt-backup` Features:

* Ability to backup all the VM's disks or only system disk
* compress  the backup in a ZIP file, which helps to decrease backup size
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

* Backup a VM with only system disk disks

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

* Delete the VM



* Restore the VM







![WeFP3Uj](Images/20200203221016989_14716.png)


![](https://i.imgur.com/Q2nZkyd.png)


![](https://i.imgur.com/UhfiMiq.png)












