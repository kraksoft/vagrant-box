#!/bin/bash

BUILD_OSNAME="debian"
BUILD_OSTYPE="Debian_64"

BOX="debian-8.1.0-amd64"
ISO_URL="http://debian.apt-get.eu/cd-images/8.1.0/amd64/iso-cd/debian-8.1.0-amd64-netinst.iso"
ISO_MD5="1a311f9afb68d6365211b13b4342c40b"

./build.sh ${BUILD_OSNAME} ${BUILD_OSTYPE} ${BOX} ${ISO_URL} ${ISO_MD5}
