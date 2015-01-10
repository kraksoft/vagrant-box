#!/bin/bash

# Configurations
BUILD_OSNAME="debian"
BUILD_OSTYPE="Debian_64"
BOX="debian-7.6.0-amd64"
ISO_URL="http://cdimage.debian.org/mirror/cdimage/archive/7.6.0/amd64/iso-cd/debian-7.6.0-amd64-netinst.iso"
ISO_MD5="8a3c2ad7fd7a9c4c7e9bcb5cae38c135"

./build.sh ${BUILD_OSNAME} ${BUILD_OSTYPE} ${BOX} ${ISO_URL} ${ISO_MD5}
