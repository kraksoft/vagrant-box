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

# display all while boot
sed "s|""LINUX_DEFAULT="".*|LINUX_DEFAULT=\"\"|" /etc/default/grub > /tmp/grub
sed "s|GRUB_TIMEOUT=[0-9]|GRUB_TIMEOUT=1|" /tmp/grub > /etc/default/grub
update-grub

sudo apt-get -y -qq install linux-headers-$(uname -r) build-essential dkms nfs-common zerofree
sudo apt-get -y -qq install vim-nox ranger mc bash-completion aptitude

cat > /initzerofree << !EOF!
#!/bin/bash
init 1
echo ' === [ zerofree /dev/sda1 ] === '
mount -n -o remount,ro /dev/sda1 /
zerofree -v /dev/sda1
mount -n -o remount,rw /dev/sda1 /
sync
sed -i "s|""LINUX_DEFAULT="".*|LINUX_DEFAULT=\"\"" /etc/default/grub
update-grub

rm -f /initzerofree

## try correct shutdown ..
# run scripts from init 0
find /etc/rc0.d -type l | sort | xargs -I {} -n 1 /bin/bash {} stop

exit 0
!EOF!
chmod +x /initzerofree

cat > /home/vagrant/vba.sh << !EOF!
#!/bin/bash

mount /dev/cdrom /media/cdrom
sh /media/cdrom/VBoxLinuxAdditions.run --nox11

mv /etc/rc.local.bak /etc/rc.local

# replace init script to zerofree hdd
sed -i "s|""LINUX_DEFAULT="".*|LINUX_DEFAULT=\" single init=/initzerofree \"|" /etc/default/grub
update-grub

#reboot for zerofree
reboot

!EOF!
cp /etc/rc.local /etc/rc.local.bak && cat /home/vagrant/vba.sh > /etc/rc.local
rm -f /home/vagrant/vba.sh

# clean up
apt-get autoremove --yes
apt-get clean

#agressive clean
rm -Rf /var/lib/apt/*
rm -Rf /var/log/installer

rm -Rf /var/log/*.gz
rm -Rf /var/log/*.1
rm -Rf /var/log/*.0 
## clear oll log data
for logfile in /var/log/*.log ; do
  echo '' > $logfile
done

rm -rf /usr/share/doc
find /var/cache -type f -exec rm -rf {} \;
## remove locales ... 
#rm -rf /usr/share/locale/{af,am,ar,as,ast,az,bal,be,bg,bn,bn_IN,br,bs,byn,ca,cr,cs,csb,cy,da,de,de_AT,dz,el,en_AU,en_CA,eo,es,et,et_EE,eu,fa,fi,fo,fr,fur,ga,gez,gl,gu,haw,he,hi,hr,hu,hy,id,is,it,ja,ka,kk,km,kn,ko,kok,ku,ky,lg,lt,lv,mg,mi,mk,ml,mn,mr,ms,mt,nb,ne,nl,nn,no,nso,oc,or,pa,pl,ps,pt,pt_BR,qu,ro,rw,si,sk,sl,so,sq,sr,sr*latin,sv,sw,ta,te,th,ti,tig,tk,tl,tr,tt,ur,urd,ve,vi,wa,wal,wo,xh,zh,zh_HK,zh_CN,zh_TW,zu}
find /usr/share/locale/ -type d -print0 | grep -v en | xargs -0 rm -rf

# Zero free space to aid VM compression
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
