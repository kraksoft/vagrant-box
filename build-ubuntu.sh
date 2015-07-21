#!/bin/bash

BUILD_OSNAME="ubuntu"
BUILD_OSTYPE="Ubuntu_64"

BOX="ubuntu-15.04-amd64"
ISO_URL="http://releases.ubuntu.com/releases/15.04/ubuntu-15.04-server-amd64.iso"
ISO_MD5="487f4a81f22f8597503db3d51a1b502e"

./build.sh ${BUILD_OSNAME} ${BUILD_OSTYPE} ${BOX} ${ISO_URL} ${ISO_MD5}
