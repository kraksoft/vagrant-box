#!/bin/bash

BUILD_OSNAME="debian"
BUILD_OSTYPE="Debian_64"

BOX="debian-7.8.0-amd64"
ISO_URL="http://debian.apt-get.eu/cd-images/7.8.0/amd64/iso-cd/debian-7.8.0-amd64-netinst.iso"
ISO_MD5="a91fba5001cf0fbccb44a7ae38c63b6e"

./build.sh ${BUILD_OSNAME} ${BUILD_OSTYPE} ${BOX} ${ISO_URL} ${ISO_MD5}
