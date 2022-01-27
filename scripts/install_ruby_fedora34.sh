#!/bin/bash -e
dnf module reset ruby
dnf module install -y 
ruby:2.5
dnf --allowerasing distro-sync

