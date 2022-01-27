#!/bin/bash -e
echo """
**************************************
      Install Virt-Backup
**************************************
"""

gem install rubysl-tempfile
gem install rubysl-optparse
gem install open4
gem uninstall zip # Need to be removed if installed
gem install rubyzip

cd /var
git clone https://github.com/eslam-gomaa/virt-backup.git
# alias virt-backup="ruby /var/virt-backup/virt-backup.rb"
# virt-backup -h
export virt_backup="ruby /var/virt-backup/virt-backup.rb"
$virt_backup -h