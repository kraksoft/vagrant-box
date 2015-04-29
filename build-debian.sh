#!/bin/bash
cd "$(dirname ""$0"")"

# some magick from 
# https://github.com/tiwilliam/vagrant-debian
set -e
argv=($@)
case ${argv[0]} in
    32)
        ARCH="i386"
        OS_TYPE="Debian"
    ;;
    64)
        ARCH="amd64"
        OS_TYPE="Debian_64"
    ;;
    *)
        echo "usage: $0 <32|64>"
        exit
    ;;
esac

# start bercut497 magick
# https://github.com/bercut497/vagrant-box
BUILD_OSNAME="debian"
DEBIAN_URI="http://cdimage.debian.org/debian-cd/current/${ARCH}/iso-cd"

md5str="$( curl ""${DEBIAN_URI}/MD5SUMS"" | awk ' /'debian-[0-9].[0-9].[0-9]-${ARCH}-netinst.iso'/ { print }')"
#echo ${md5str}

ISO_MD5="$( echo ${md5str} | cut -d' ' -f1 )"
#echo ${ISO_MD5}

ISO_FILE="$( echo ${md5str} | cut -d' ' -f2 )"
#echo ${ISO_FILE}
ISO_URL="${DEBIAN_URI}/${ISO_FILE}"
 
BOX="${ISO_FILE:0:12}-${ARCH}"
#echo ${BOX}

#BOX="debian-8.0.0-i386"
#ISO_URL="http://cdimage.debian.org/debian-cd/8.0.0/i386/iso-cd/debian-8.0.0-i386-netinst.iso"
#ISO_MD5="72045f21b78824023ad665c2ef387c26"

#debug enable
#export VM_GUI='yes';

./build-current.sh ${BUILD_OSNAME} ${OS_TYPE} ${BOX} ${ISO_URL} ${ISO_MD5}
