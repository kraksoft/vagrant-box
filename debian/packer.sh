#!/bin/bash

# check required parameters number
if [ $# -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# Configurations
BOX=$1

echo "Building ""${BOX}""  Vagrant Box ..."
vagrant package --base "${BOX}" --output "${BOX}.box"
md5sum -b "${BOX}.box" > "${BOX}.box.md5"

echo "Adding Vagrant Box ..."
vagrant box add --force "${BOX}" "${BOX}.box"

# references:
# https://github.com/dotzero/vagrant-debian-wheezy-64
# https://github.com/cal/vagrant-ubuntu-precise-64
# http://blog.ericwhite.ca/articles/2009/11/unattended-debian-lenny-install/
# http://docs-v1.vagrantup.com/v1/docs/base_boxes.html
# http://www.debian.org/releases/stable/example-preseed.txt
