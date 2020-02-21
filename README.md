# virt-backup :rocket:
Fully backup & restore your KVM Virtual Machines 

**Version**  `1.0` Stable 

---

## `virt-backup` Features:

* Ability to backup all the VM's disks or only system disk
* compress the backup **directly** in a ZIP file, which decreases backup size
* validate the restore process with the checksum of the original VM (taken on backup)
* Ability to backup and restore all the VM's snapshot - [ **Internal Snapshots** ]


---

## Install

* Just install the gems used and you're good to go *(Assuming that you have KVM installed)*

```bash
yum install -y ruby
```
> OR
```bash
apt-get install -y ruby
```

```bash
gem install rubysl-tempfile
gem install rubysl-optparse
gem install open4
gem install OptionParser
gem install zip
```

```bash
git clone https://github.com/Eslam-Naser/virt-backup.git
cd virt-backup
ruby virt-backup.rb --help
```

---

#### Installation test result

| Distro             | Test Result |
| ------------------ | ----------- |
| `Ubuntu 16.04 LTS` | ✔️           |
| `Centos 7`         | ✔️           |


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

## Example screenshoots



* Backup

```bash
ruby /root/virt-backup/virt-backup.rb \
  --backup \
  --original-vm snap23 \
  --save-dir /var/lib/libvirt/images/backup-11/ \
  --with-snapshots
```

![](https://i.imgur.com/msxoiYc.png)



* Restore

```bash
ruby /root/virt-backup/virt-backup.rb \
  --restore \
  --with-snapshots \
  --backup-file /var/lib/libvirt/images/backup-11/snap23.zip 
  --restore-dir /var/lib/libvirt/images
```

![Imgur](https://i.imgur.com/Uoh7Zpq.png)



### To be added (for now) 🔨

* Description for the methods used inside the code

### Updates & Fixes

* If md5 mismatch found, print where is the difference ✔️
* Pause the VM before collecting the checksum ✔️
* Fix: Error if snapshot name has a space ✔️
* Fix: Restore snapshot --> stable now 

---

Thank you

Eslam Gomaa

