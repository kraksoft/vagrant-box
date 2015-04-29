#!/bin/bash

# passwordless sudo
echo "%sudo   ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# add vagrant user rule
echo "vagrant   ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/vagrant

# public ssh key for vagrant user
mkdir /home/vagrant/.ssh
wget -O /home/vagrant/.ssh/authorized_keys "https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub"
chmod 755 /home/vagrant/.ssh
chmod 644 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# speed up ssh
echo "UseDNS no" >> /etc/ssh/sshd_config

# remove debian boot error "Driver pcspkr is already registered, aborting..."
echo "blacklist pcspkr" >> /etc/modprobe.d/blacklist.conf

# display login promt after boot
sed "s/quiet splash//" /etc/default/grub > /tmp/grub
sed "s/GRUB_TIMEOUT=[0-9]/GRUB_TIMEOUT=1/" /tmp/grub > /etc/default/grub
update-grub

## VIRTUALBOXGUESTADDITION DOWNLOADER BEGIN
# comment next lines if you dont want download VBoxGuestAdditions.iso
# and setup VirtualBox Guest Additions in this step
#

sudo apt-get -y -qq install linux-headers-$(uname -r) build-essential dkms nfs-common
sudo apt-get -y -qq install curl vim-nox ranger mc bash-completion aptitude

# install virtual box additions for that VirtualBox version.
VBOXVER="0.0.00"

# set sun CDN. 
# example: http://dlc-cdn.sun.com/virtualbox/4.3.26/VBoxGuestAdditions_4.3.26.iso
VBOXCDN="http://dlc-cdn.sun.com/virtualbox"
VBOXISO_URL="${VBOXCDN}/${VBOXVER}/VBoxGuestAdditions_${VBOXVER}.iso"
# downloaded file path. 
#VBOXISO_FILE="/tmp/vbox.iso"
VBOXISO_FILE="/home/vagrant/vbox.iso"
# enable logging.
# to disable set "/dev/null"
#VBOX_LOG="/dev/null"
VBOX_LOG="/home/vagrant/vbox-additions.log"
curl "${VBOXISO_URL}" -o ${VBOXISO_FILE}
if [ ! -f "${VBOXISO_FILE}" ]; then
  echo -e "ERROR: Cant get ${VBOXISO_FILE} from \n ${VBOXISO_URL} " >> "${VBOX_LOG}"
else
  echo "SUCCESS: Get ${VBOXISO_FILE} from \n ${VBOXISO_URL} " >> "${VBOX_LOG}"
  chown vagrant:vagrant ${VBOXISO_FILE}
  sudo -n mount -o loop "${VBOXISO_FILE}" /mnt
  sh /mnt/VBoxLinuxAdditions.run --nox11 >> "${VBOX_LOG}"
  if [ "$( lsmod | grep -i 'vbox' -c )" -lt 4 ] ; then
    echo "ERROR: DKMS modules not installed. (save iso file ${VBOXISO_FILE} )" >> "${VBOX_LOG}"
  else
    echo "SUCCESS: DKMS modules installed. (remove iso file)" >> "${VBOX_LOG}"
    # print installed modules
    lsmod | grep 'vbox' >>  "${VBOX_LOG}"
    rm -f "${VBOXISO_FILE}"
  fi
fi

# clean up
apt-get autoremove --yes
apt-get clean

# Zero free space to aid VM compression
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
