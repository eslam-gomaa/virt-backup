# virt-backup :rocket:
Fully backup & restore your KVM Virtual Machines 

**Version**  `Beta 1.1` 

---

## `virt-backup` Features:

* Ability to backup all the VM's disks or only system disk
* compress the backup **directly** in a ZIP file, which decreases backup size
* validate the restore process with the checksum of the original VM (taken on backup)
* Ability to backup and restore all the VM's snapshot  [ **Expremental** ]


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
gem install xmlrpc
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

`Note` Ignore the following error on `Centos` as it works normally

> `ERROR:  Error installing xmlrpc:` 



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


* Backup a VM

```bash
ruby virt-backup.rb --backup \
 --with-snapshots \
 --original-vm kube-2 \
 --save-dir /var/lib/libvirt/images/backup-4/
```

![](https://i.imgur.com/W8YRsGD.png)


* Restore the VM

```bash
ruby virt-backup.rb --restore \
 --with-snapshots \
 --backup-file /var/lib/libvirt/images/backup-4/kube-2.zip \
 --restore-dir /var/lib/libvirt/images
```

![](https://i.imgur.com/A0JHddH.png)

---


### To be added (for now) 🔨

* Description for the methods used inside the code
* Do more tests to `--with-snapshot` to eliminate any warning
* Check md5 when backing up as well
* use `--force` to skip rolling back in case of md5 mismatch

### Updates & Fixes

* If md5 mismatch found, print where is the difference ✔️
* Pause the VM before collecting the checksum ✔️
* Fix: Error if snapshot name has a space ✔️

---

Thank you

Eslam Gomaa

