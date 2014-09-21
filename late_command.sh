#!/bin/bash

# passwordless sudo
echo "%sudo   ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

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

# make sure, you have virtualbox-guest packages NOT preinstalled /why they are?/, because...
# - if you do not use it: they are not needed
# - if you use it: it's better to install it manually, otherwise they can be a cause of problems with vagrant-vbguest plugin update
apt-get purge --yes virtualbox-guest-* virtualbox-ose-guest-*

# clean up
apt-get autoremove --yes
apt-get clean

# Zero free space to aid VM compression
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
