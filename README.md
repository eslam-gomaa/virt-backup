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

At least Ruby Version `2.4` is needed, Here is how to [install Ruby 2.5 on different distributions](docs/Install_Ruby.md)

> Just install the gems used and you're good to go *(Assuming that you have KVM installed)*


```bash
gem install rubysl-tempfile
gem install rubysl-optparse
gem install open4
gem uninstall zip # Need to be removed if installed
gem install rubyzip
```

```bash
git clone https://github.com/eslam-gomaa/virt-backup.git
cd virt-backup
ruby virt-backup.rb --help
```

> ##### Prefered way to install
>---
> ```bash
> cd /var
> git clone https://github.com/eslam-gomaa/virt-backup.git
> alias virt-backup="ruby /var/virt-backup/virt-backup.rb"
> # Put it in ~/.bashrc for persistence.
> # echo 'alias virt-backup="ruby /var/virt-backup/virt-backup.rb"' >> ~/.bashrc
> virt-backup -h
> ```

---

### Test

📌 The tests are done by an automated Jenkins [pipeline](https://github.com/eslam-gomaa/virt-backup/blob/master/Jenkinsfile)

| Distro         | Test Result |
| -------------- | ----------- |
| `Ubuntu 16.04` |![](https://jenkins.demo.devops-caffe.com/jenkins/buildStatus/icon?job=virt-backup%2Fmaster&config=ubuntu_16_04)|
| `Ubuntu 18.04` |![](https://jenkins.demo.devops-caffe.com/jenkins/buildStatus/icon?job=virt-backup%2Fmaster&config=ubuntu_18_04)|
| `Ubuntu 20.04` |![](https://jenkins.demo.devops-caffe.com/jenkins/buildStatus/icon?job=virt-backup%2Fmaster&config=ubuntu_20_04)|
| `CentOS 7`    |![](https://jenkins.demo.devops-caffe.com/jenkins/buildStatus/icon?job=virt-backup%2Fmaster&config=centos_7)|
| `CentOS 8`    |![](https://jenkins.demo.devops-caffe.com/jenkins/buildStatus/icon?job=virt-backup%2Fmaster&config=centos_8)|
| `fedora-34`   |![](https://jenkins.demo.devops-caffe.com/jenkins/buildStatus/icon?job=virt-backup%2Fmaster&config=fedora34)|
| `Debian 10`   |![](https://jenkins.demo.devops-caffe.com/jenkins/buildStatus/icon?job=virt-backup%2Fmaster&config=debian10)|
| `Debian 11`   |![](https://jenkins.demo.devops-caffe.com/jenkins/buildStatus/icon?job=virt-backup%2Fmaster&config=debian11)|

<br>

> #### Note for **`Debian 11`** Users (Consider that [issue](https://github.com/eslam-gomaa/virt-backup/issues/4))
> It works fine on my tests, but if you'll use the `--with-snapshots` or `-s` option make sure to test to restore your VM


<br>

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

> **supported (--compression) values are:**  `default`, `none`, `best`
> **Default:** `best`

```bash
ruby virt-backup.rb --backup \
 --with-snapshots \
 --original-vm kubernetes-master \
 --system-disk-only \
 --compression none
 --save-dir /var/lib/libvirt/images/backup/
```



## Example screenshots
Assuming you have installed [this way](https://github.com/eslam-gomaa/virt-backup#prefered-way-to-install)


🚩 Backup

```bash
mkdir /var/lib/libvirt/images/backup/

virt-backup --backup \
  --with-snapshots \
  --original-vm cirros \
  --save-dir /var/lib/libvirt/images/backup/
```

![image](https://user-images.githubusercontent.com/33789516/151503493-d694cdc4-04bd-4632-a57a-e493187ed875.png)




🚩 Restore

```bash
virt-backup --restore \
  --with-snapshots \
  --backup-file /var/lib/libvirt/images/backup/cirros.zip \
  --restore-dir /var/lib/libvirt/images/
```

![image](https://user-images.githubusercontent.com/33789516/151503844-135d283b-1400-411e-9b5b-deaf54131c47.png)

<br>

<br>




### Updates & Fixes

* If md5 mismatch found, print where is the difference ✔️
* Pause the VM before collecting the checksum ✔️
* Fix: Error if snapshot name has a space ✔️
* Fix: Restore snapshot --> stable now ✔️
* Update: Zip 64 bit is added (the support to backup & restore large disk files) ✔️
* Add command-line control to the compression level ✔️

---

<br>

***Note***  
The script does the job perfectly, However to add more features easily the code needs to be refactored,

And since that would take a few weeks, at least 3 features/enhancements should be requested first.

<br>

---


Thank you

[Eslam Gomaa](https://www.linkedin.com/in/eslam-gomaa/)

.
