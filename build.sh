#!/bin/bash

# check required parameters number
if [ $# -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

# Configurations
BUILD_OSNAME=$1
BUILD_OSTYPE=$2
BOX=$3
ISO_URL=$4
ISO_MD5=$5

# make sure we have dependencies
hash VBoxManage 2>/dev/null || { echo >&2 "ERROR: VBoxManage not found.  Aborting."; exit 1; }
hash vagrant 2>/dev/null || { echo >&2 "ERROR: vagrant not found.  Aborting."; exit 1; }
hash 7z 2>/dev/null || { echo >&2 "ERROR: 7z not found. Aborting."; exit 1; }
hash curl 2>/dev/null || { echo >&2 "ERROR: curl not found. Aborting."; exit 1; }

VBOX_VERSION="$(VBoxManage --version)"

if hash mkisofs 2>/dev/null; then
  MKISOFS="$(which mkisofs)"
elif hash genisoimage 2>/dev/null; then
  MKISOFS="$(which genisoimage)"
else
  echo >&2 "ERROR: mkisofs or genisoimage not found.  Aborting."
  exit 1
fi

set -o nounset
set -o errexit
#set -o xtrace

# location, location, location
FOLDER_ROOT=$(pwd)
FOLDER_BASE="${FOLDER_ROOT}/${BUILD_OSNAME}"
FOLDER_ISO="${FOLDER_BASE}/iso"
FOLDER_BUILD="${FOLDER_BASE}/build"
FOLDER_VBOX="${FOLDER_BUILD}/vbox"
FOLDER_ISO_CUSTOM="${FOLDER_BUILD}/iso/custom"
FOLDER_ISO_INITRD="${FOLDER_BUILD}/iso/initrd"

# Env option: Use headless mode or GUI
VM_GUI="${VM_GUI:-}"
if [ "x${VM_GUI}" == "xyes" ] || [ "x${VM_GUI}" == "x1" ]; then
  STARTVM="VBoxManage startvm ${BOX}"
else
  STARTVM="VBoxManage startvm ${BOX} --type headless"
fi
STOPVM="VBoxManage controlvm ${BOX} poweroff"

# Env option: Use custom preseed.cfg or default
DEFAULT_PRESEED="${FOLDER_BASE}/preseed.cfg"
PRESEED="${PRESEED:-"$DEFAULT_PRESEED"}"

# Env option: Use custom isolinux.cfg or default
DEFAULT_ISOLINUX="${FOLDER_ROOT}/isolinux.cfg"
ISOLINUX="${ISOLINUX:-"$DEFAULT_ISOLINUX"}"

# Env option: Use custom late_command.sh or default
DEFAULT_LATE_CMD="${FOLDER_ROOT}/late_command.sh"
LATE_CMD="${LATE_CMD:-"$DEFAULT_LATE_CMD"}"

# Env option: Use custom hdd size or default
DEFAULT_HDD_SIZE="51200"
HDD_SIZE="${HDD_SIZE:-"$DEFAULT_HDD_SIZE"}"

# Parameter changes from 4.2 to 4.3
if [[ "$VBOX_VERSION" < 4.3 ]]; then
  PORTCOUNT="--sataportcount 1"
else
  PORTCOUNT="--portcount 1"
fi

if [ "$OSTYPE" = "linux-gnu" ]; then
  MD5="md5sum"
elif [ "$OSTYPE" = "msys" ]; then
  MD5="md5 -l"
else
  MD5="md5 -q"
fi

# start with a clean slate
if VBoxManage list runningvms | grep "${BOX}" >/dev/null 2>&1; then
  echo "Stopping vm ..."
  ${STOPVM}
fi
if VBoxManage showvminfo "${BOX}" >/dev/null 2>&1; then
  echo "Unregistering vm ..."
  VBoxManage unregistervm "${BOX}" --delete
fi
if [ -d "${FOLDER_BUILD}" ]; then
  echo "Cleaning build directory ..."
  chmod -R u+w "${FOLDER_BUILD}"
  rm -rf "${FOLDER_BUILD}"
fi
if [ -f "${FOLDER_ISO}/custom.iso" ]; then
  echo "Removing custom iso ..."
  rm "${FOLDER_ISO}/custom.iso"
fi
if [ -f "${FOLDER_BASE}/${BOX}.box" ]; then
  echo "Removing old ${BOX}.box" ...
  rm "${FOLDER_BASE}/${BOX}.box"
fi

if [ -d "${FOLDER_ISO_CUSTOM}" ]; then
  echo "Removing old ${FOLDER_ISO_CUSTOM} ..."
  chmod -R u+w "${FOLDER_ISO_CUSTOM}"
  rm -rf "${FOLDER_ISO_CUSTOM}/*"
fi

if [ -d "${FOLDER_ISO_INITRD}" ]; then
  echo "Removing old ${FOLDER_ISO_INITRD} ..."
  chmod -R u+w "${FOLDER_ISO_INITRD}"
  rm -rf "${FOLDER_ISO_INITRD}/*"
fi

# Setting things back up again
mkdir -p "${FOLDER_ISO}"
mkdir -p "${FOLDER_BUILD}"
mkdir -p "${FOLDER_VBOX}"
mkdir -p "${FOLDER_ISO_CUSTOM}"
mkdir -p "${FOLDER_ISO_INITRD}"

ISO_FILENAME="${FOLDER_ISO}/`basename ${ISO_URL}`"
INITRD_FILENAME="${FOLDER_ISO}/initrd.gz"

# download the installation disk if you haven't already or it is corrupted somehow
echo "Downloading `basename ${ISO_URL}` ..."
if [ ! -e "${ISO_FILENAME}" ]; then
  curl --output "${ISO_FILENAME}" -L "${ISO_URL}"
fi

# make sure download is right...
ISO_HASH=$(${MD5} "${ISO_FILENAME}" | cut -d ' ' -f 1)
if [ "${ISO_MD5}" != "${ISO_HASH}" ]; then
  echo "ERROR: MD5 does not match. Got ${ISO_HASH} instead of ${ISO_MD5}. Aborting."
  exit 1
fi

# customize it
echo "Creating Custom ISO"
if [ ! -e "${FOLDER_ISO}/custom.iso" ]; then

  echo "Using 7zip"
  7z x "${ISO_FILENAME}" -o"${FOLDER_ISO_CUSTOM}"

  # If that didn't work, you have to update p7zip
  if [ ! -e ${FOLDER_ISO_CUSTOM} ]; then
    echo "Error with extracting the ISO file with your version of p7zip. Try updating to the latest version."
    exit 1
  fi

  # small @hack
  if [ "${BUILD_OSNAME}" = "ubuntu" ]; then
    mv "${FOLDER_ISO_CUSTOM}/install" "${FOLDER_ISO_CUSTOM}/install.amd"
    mkdir -p "${FOLDER_ISO_CUSTOM}/install"
  fi

  # backup initrd.gz
  echo "Backing up current init.rd ..."
  FOLDER_INSTALL=$(ls -1 -d "${FOLDER_ISO_CUSTOM}/install."* | sed 's/^.*\///')
  chmod u+w "${FOLDER_ISO_CUSTOM}/${FOLDER_INSTALL}" "${FOLDER_ISO_CUSTOM}/install" "${FOLDER_ISO_CUSTOM}/${FOLDER_INSTALL}/initrd.gz"
  cp -r "${FOLDER_ISO_CUSTOM}/${FOLDER_INSTALL}/"* "${FOLDER_ISO_CUSTOM}/install/"
  mv "${FOLDER_ISO_CUSTOM}/install/initrd.gz" "${FOLDER_ISO_CUSTOM}/install/initrd.gz.org"

  # stick in our new initrd.gz
  echo "Installing new initrd.gz ..."
  cd "${FOLDER_ISO_INITRD}"
  if [ "$OSTYPE" = "msys" ]; then
    gunzip -c "${FOLDER_ISO_CUSTOM}/install/initrd.gz.org" | cpio -i --make-directories || true
  else
    gunzip -c "${FOLDER_ISO_CUSTOM}/install/initrd.gz.org" | cpio -id || true
  fi
  cd "${FOLDER_BASE}"
  if [ "${PRESEED}" != "${DEFAULT_PRESEED}" ] ; then
    echo "Using custom preseed file ${PRESEED}"
  fi
  cp "${PRESEED}" "${FOLDER_ISO_INITRD}/preseed.cfg"
  cd "${FOLDER_ISO_INITRD}"
  find . | cpio --create --format='newc' | gzip  > "${FOLDER_ISO_CUSTOM}/install/initrd.gz"

  # clean up permissions
  echo "Cleaning up Permissions ..."
  chmod u-w "${FOLDER_ISO_CUSTOM}/install" "${FOLDER_ISO_CUSTOM}/install/initrd.gz" "${FOLDER_ISO_CUSTOM}/install/initrd.gz.org"

  # replace isolinux configuration
  echo "Replacing isolinux config ..."
  cd "${FOLDER_BASE}"
  chmod u+w "${FOLDER_ISO_CUSTOM}/isolinux" "${FOLDER_ISO_CUSTOM}/isolinux/isolinux.cfg"
  rm "${FOLDER_ISO_CUSTOM}/isolinux/isolinux.cfg"
  cp "${ISOLINUX}" "${FOLDER_ISO_CUSTOM}/isolinux/isolinux.cfg"
  chmod u+w "${FOLDER_ISO_CUSTOM}/isolinux/isolinux.bin"

  # add late_command script
  echo "Add late_command script ..."
  chmod u+w "${FOLDER_ISO_CUSTOM}"
  cp "${LATE_CMD}" "${FOLDER_ISO_CUSTOM}/late_command.sh"

  # set Virtual box version for download ISO
  VBOXVER="${VBOX_VERSION:0:6}"
  sed -i "s|^""VBOXVER="".*|""VBOXVER=\"${VBOXVER}\"""|g" "${FOLDER_ISO_CUSTOM}/late_command.sh"

  echo "Running mkisofs ..."
  "$MKISOFS" -r -V "Custom Install CD" \
    -cache-inodes -quiet \
    -J -l -b isolinux/isolinux.bin \
    -c isolinux/boot.cat -no-emul-boot \
    -boot-load-size 4 -boot-info-table \
    -o "${FOLDER_ISO}/custom.iso" "${FOLDER_ISO_CUSTOM}"
fi

echo "Creating VM Box..."
# create virtual machine
if ! VBoxManage showvminfo "${BOX}" >/dev/null 2>&1; then
  VBoxManage createvm \
    --name "${BOX}" \
    --ostype "${BUILD_OSTYPE}" \
    --register \
    --basefolder "${FOLDER_VBOX}"

  VBoxManage modifyvm "${BOX}" \
    --memory 512 \
    --boot1 disk \
    --boot2 dvd \
    --boot3 none \
    --boot4 none \
    --vram 16 \
    --pae on \
    --rtcuseutc on

  VBoxManage storagectl "${BOX}" \
    --name "IDE Controller" \
    --add ide \
    --controller PIIX4 \
    --hostiocache on

  VBoxManage storageattach "${BOX}" \
    --storagectl "IDE Controller" \
    --port 0 \
    --device 0 \
    --type dvddrive \
    --medium "${FOLDER_ISO}/custom.iso"

  VBoxManage storagectl "${BOX}" \
    --name "SATA Controller" \
    --add sata \
    --controller IntelAhci \
    ${PORTCOUNT} \
    --hostiocache off

  VBoxManage createhd \
    --filename "${FOLDER_VBOX}/${BOX}/${BOX}.vdi" \
    --size ${HDD_SIZE}

  VBoxManage storageattach "${BOX}" \
    --storagectl "SATA Controller" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "${FOLDER_VBOX}/${BOX}/${BOX}.vdi"

  ${STARTVM}

  echo -n "Waiting for installer to finish "
  while VBoxManage list runningvms | grep "${BOX}" >/dev/null; do
    sleep 20
    echo -n "."
  done
  echo ""

# sometimes vagrant get error if VBoxGuestAdditions.iso
# not installed in host system. 
  VBoxManage storagectl "${BOX}" \
    --name "IDE Controller" \
    --remove

#  VBoxManage storageattach "${BOX}" \
#    --storagectl "IDE Controller" \
#    --port 0 \
#    --device 0 \
#    --type dvddrive \
#    --medium additions
fi

echo "Building Vagrant Box ..."
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
