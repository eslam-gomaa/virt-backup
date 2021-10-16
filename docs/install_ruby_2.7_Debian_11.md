## Debian 11 (Bullseye) Ruby Install Instructions

These instructions will install `Ruby 2.7` on **Debian 11 (Bullseye)**.

### Install Ruby 2.7

```bash
apt-get update
apt-get install -y ruby
```

### Install the gems

```bash
gem install rubysl-tempfile
gem install rubysl-optparse
gem install open4
gem install rubyzip
```

### Clone and Run virt-backup

```bash
cd /opt
git clone https://github.com/Eslam-Naser/virt-backup.git
cd virt-backup
ruby virt-backup.rb --help
```

### (Optional) Create an alias

In order to run `virt-backup.rb` from anywhere you can create the following alias by 
copying and pasting these three lines.

```bash
cat <<EOF >>~/.bash_aliases
alias virt-backup="cd /opt/virt-backup/ ; ruby virt-backup.rb"
EOF
```

To load the alias just run `source ~/.bash_aliases` and then:

```console
$ virt-backup --help
Usage: virt-backup.rb --backup | --restore [options]
    -B, --backup                     Backup KVM VM
    -R, --restore                    Restore KVM VM
    -s, --with-snapshots             Backup the Snapshots along with the VM
    -S, --system-disk-only           Backup the system disk only
    -o, --original-vm                Original VM to be Cloned
    -D, --save-dir                   Backup save directory
    -d, --backup-file                ZIP File which represents the VM backup
    -r, --restore-dir                Restore directory, with --restore
    -c, --compression                Choose the compression level; Default: default
```
