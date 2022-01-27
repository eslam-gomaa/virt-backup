# virt-backup :rocket:
Fully backup & restore your KVM Virtual Machines 


---

## `virt-backup` Features:

* Ability to backup all the VM's disks or only system disk
* compress the backup **directly** in a ZIP file, which decreases backup size
* validate the restore process with the checksum of the original VM (taken on backup)
* Ability to backup and restore all the VM's snapshot - [ **Internal Snapshots** ]


---

## Install

* At least Ruby Version `2.4` is needed

* Just install the gems used and you're good to go *(Assuming that you have KVM installed)*



> To Install Ruby 2.4 on **CentOS** you can follow these steps [install_ruby_2.4.2_CentOS.md](docs/install_ruby_2.4.2_CentOS.md)



> For **Ubuntu** it's easy to install ruby 2.5
```bash
apt-get install -y ruby
apt update ruby # By default you'll install Ruby 2.5
```

```bash
gem install rubysl-tempfile
gem install rubysl-optparse
gem install open4
gem uninstall zip # Need to be removed if installed
gem install rubyzip
```

```bash
git clone https://github.com/Eslam-Naser/virt-backup.git
cd virt-backup
ruby virt-backup.rb --help
```

> To install Ruby 2.7 on **Debian 11 (Bullseye)** you can follow the steps contained in the 
[install_ruby_2.7_Debian_11.md](docs/install_ruby_2.7_Debian_11.md) document. 

---

#### Installation test result

| Distro         | Test Result |
| -------------- | ----------- |
| `Ubuntu 16.04` |https://jenkins.demo.devops-caffe.com/jenkins/buildStatus/icon?job=virt-backup%2Fmaster&config=ubuntu_16_04|
| `Ubuntu 18.04` |https://jenkins.demo.devops-caffe.com/jenkins/buildStatus/icon?job=virt-backup%2Fmaster&config=ubuntu_18_04|
| `Centos 7`     |https://jenkins.demo.devops-caffe.com/jenkins/buildStatus/icon?job=virt-backup%2Fmaster&config=ubuntu_20_04|
| `Debian 11`    | 🟠          |
| `....`     | 🟢          |
| `....`     | 🟢          |
| `....`     | 🟢          |

**Note for Debian users:** backups using the `--with-snapshots`, or `-s` option will succeed but restoring the backup fails. [See this issue](https://github.com/eslam-gomaa/virt-backup/issues/4) for more details on the matter. For now, make sure you omit the with snapshots option flag when creating a backup. Everything else works perfectly.

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



* Backup without compression

> supported  (--compression) values are:  default, none, best

```bash
ruby virt-backup.rb --backup \
 --with-snapshots \
 --original-vm kubernetes-master \
 --system-disk-only \
 --compression none
 --save-dir /var/lib/libvirt/images/backup/
```



## Example screenshots



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
  --backup-file /var/lib/libvirt/images/backup-11/snap23.zip \
  --restore-dir /var/lib/libvirt/images
```

![Imgur](https://i.imgur.com/Uoh7Zpq.png)





### Updates & Fixes

* If md5 mismatch found, print where is the difference ✔️
* Pause the VM before collecting the checksum ✔️
* Fix: Error if snapshot name has a space ✔️
* Fix: Restore snapshot --> stable now ✔️
* Update: Zip 64 bit is added (the support to backup & restore large disk files) ✔️
* Add command-line control to the compression level ✔️

---



Thank you

[Eslam Gomaa](https://www.linkedin.com/in/eslam-gomaa/)

