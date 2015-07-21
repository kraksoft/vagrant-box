#!/bin/bash

BUILD_OSNAME="ubuntu"
BUILD_OSTYPE="Ubuntu_64"

BOX="ubuntu-14.10-amd64"
ISO_URL="http://releases.ubuntu.com/releases/14.10/ubuntu-14.10-server-amd64.iso"
ISO_MD5="91bd1cfba65417bfa04567e4f64b5c55"

./build.sh ${BUILD_OSNAME} ${BUILD_OSTYPE} ${BOX} ${ISO_URL} ${ISO_MD5}
