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
sed "s/quiet splash/ single /" /etc/default/grub > /tmp/grub
sed "s/GRUB_TIMEOUT=[0-9]/GRUB_TIMEOUT=1/" /tmp/grub > /etc/default/grub
update-grub

sudo apt-get -y -qq install linux-headers-$(uname -r) build-essential dkms nfs-common zerofree
sudo apt-get -y -qq install curl vim-nox ranger mc bash-completion aptitude

cat > /home/vagrant/vba.sh << !EOF!
#!/bin/bash

mount /dev/cdrom /media/cdrom
sh /media/cdrom/VBoxLinuxAdditions.run --nox11

mv /etc/rc.local.bak /etc/rc.local

sed -i "s/ single //" /etc/default/grub
update-grub
mount -o remount,ro /
zerofree /dev/sda1

shutdown -h now
!EOF!
cp /etc/rc.local /etc/rc.local.bak && cat /home/vagrant/vba.sh > /etc/rc.local

# clean up
apt-get autoremove --yes
apt-get clean

# Zero free space to aid VM compression
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
