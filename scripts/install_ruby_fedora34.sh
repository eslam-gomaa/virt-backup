#!/bin/bash -e
dnf module reset ruby
dnf module install ruby:2.5
dnf --allowerasing distro-sync

