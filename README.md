# virt-backup :rocket:
Fully backup & restore your KVM Virtual Machines 

**Version**  `Beta 1.0` 

---

## `virt-backup` Features:

* Ability to backup all the VM's disks or only system disk
* compress the backup **directly** in a ZIP file, which decreases backup size
* validate the restore process with the checksum of the original VM (taken on backup)
* Ability to backup and restore all the VM's snapshot


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
| `Ubuntu 16.04 LTS` | ✅           |
| `Centos 7`         | ✅           |

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

## Example screesh shoots



#### Simple backup & restore

![](https://i.imgur.com/SB6FD3p.png)

![](https://i.imgur.com/69ZwK6K.png)

---

#### Fully backup the VM

* Backup a VM
```bash
ruby virt-backup.rb --backup \
 --with-snapshots \
 --original-vm kubernetes-master \
 --save-dir /var/lib/libvirt/images/backup/
```

![](https://i.imgur.com/Y6XEYTI.png)

**Notice the difference in size**
> the VM's additional 3 disks were created for testing, but compressing `2.5G` to `692M` is not bad :full_moon_with_face:

![](https://i.imgur.com/8amolTB.png)

> `Note` disk `kubernetes-master-2.img` is NOT part of the VM.

![](https://i.imgur.com/jlEP1mX.png)


* Delete the Original VM
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

![](https://i.imgur.com/e9FIu7c.png)

* Now you can start the restored VM

![](https://i.imgur.com/g1LAyHu.png)

* It might fail to restore the Snapshots if the VM is NOT running, don't worry **you'll find the snapshots XML files in the restore dir** you've specified, simply execute the following command against all the snapshot XML files

```bash
virsh snapshot-create <VM-NAME> --xmlfile <PATH-TO-SNAPSHOT-XML>
```

![](https://i.imgur.com/OcMSmgj.png)

---


### To be added (for now) 🔨

* Description for the methods used inside the code
* Do more tests to `--with-snapshot` to eliminate any warning
* Check md5 when backing up as well
* use `--force` to skip rolling back in case of md5 mismatch

### Updates & Fixes

* If md5 mismatch found, print where is the difference => [ Done 👍  ]
* Puase the VM before collecting the checksum [ Done 👍  ]

---

Thank you

Eslam Gomaa

