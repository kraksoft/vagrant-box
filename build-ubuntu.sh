#!/bin/bash
cd "$(dirname ""$0"")"

# some magick from 
# https://github.com/tiwilliam/vagrant-debian
set -e

function usage(){
    echo "usage: $0 <32|64> [LTS] "
    exit
}

if [ $# -lt 1 ] ; then
    usage;
fi

if [ $# -gt 2 ] ; then
    usage;
fi

argv=($@)
case ${argv[0]} in
    32)
        ARCH="i386"
        OS_TYPE="Ubuntu"
    ;;
    64)
        ARCH="amd64"
        OS_TYPE="Ubuntu_64"
    ;;
    *)
        usage;
    ;;
esac

# start bercut497 magick
# https://github.com/bercut497/vagrant-box
LTS=0
if [ -n "${argv[1]}" ] ; then
    if [ "${argv[1]}" = "LTS" ] ; then
        LTS=1
    else
        usage ;
    fi
fi

if [ "$( date +%m)" -lt 10 ] ;then
  V_MONTH="04"
fi

V_YEAR="$( date +%y)"
if [ "${LTS}" -eq 1 ] ; then
# LTS release every even year on april. [ref](https://wiki.ubuntu.com/LTS)
  V_MONTH="04"
#  echo "LTS SET"
  if [ "$((${V_YEAR}%2))" -eq 1 ] ; then
   V_YEAR="$((${V_YEAR} -1))"
  fi
fi

UBUNTU_VERSION="${V_YEAR}.${V_MONTH}"
#echo "${UBUNTU_VERSION}"
BUILD_OSNAME="ubuntu"
ISO_MASK="ubuntu\-${UBUNTU_VERSION}.*\-server\-${ARCH}\.iso"
UBUNTU_URI="http://releases.ubuntu.com/releases/${UBUNTU_VERSION}"

md5str="$( curl ""${UBUNTU_URI}/MD5SUMS"" | awk ' /'${ISO_MASK}'/ { print }')"
ISO_MD5="$( echo ${md5str} | cut -d' ' -f1 )"
ISO_FILE="$( echo ${md5str} | cut -d' ' -f2 )"
ISO_FILE=${ISO_FILE:1}
ISO_URL="${UBUNTU_URI}/${ISO_FILE}"
BOX="${ISO_FILE:0:-4}"

#debug enable
#export VM_GUI='yes';

# last 'non LTS' version
#BOX="ubuntu-15.04-amd64"
#ISO_URL="http://releases.ubuntu.com/releases/15.04/ubuntu-15.04-server-amd64.iso"
#ISO_MD5="487f4a81f22f8597503db3d51a1b502e"
./build.sh ${BUILD_OSNAME} ${BUILD_OSTYPE} ${BOX} ${ISO_URL} ${ISO_MD5}
