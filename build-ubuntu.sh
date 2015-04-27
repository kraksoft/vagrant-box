#!/bin/bash

BUILD_OSNAME="ubuntu"
BUILD_OSTYPE="Ubuntu_64"

# last 'LTS' version
BOX="ubuntu-14.04.2-amd64"
ISO_URL="http://releases.ubuntu.com/14.04/ubuntu-14.04.2-server-amd64.iso"
ISO_MD5="83aabd8dcf1e8f469f3c72fff2375195"

./build.sh ${BUILD_OSNAME} ${BUILD_OSTYPE} ${BOX} ${ISO_URL} ${ISO_MD5}
