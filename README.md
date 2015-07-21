## About

This script will:

 1. download the latest version of `Debian netinst` or `Ubuntu server` 64bit iso
 2. do some magic to turn it into a vagrant box file
 3. output `debian/debian-x.y.0-amd64.box` or `ubuntu/ubuntu-xx.yy-amd64.box`
 4. add just created vagrant box to available list

## Requirements

 * Oracle VM VirtualBox
 * Vagrant
 * 7zip
 * curl
 * mkisofs/genisoimage
 * md5sum/md5

## Usage on OSX

    ./build-debian.sh
or

    ./build-ubuntu.sh

This should do everything you need. If you don't have required package, install [homebrew](http://mxcl.github.com/homebrew/), then:

    brew install p7zip
    brew install curl
    brew install cdrtools
    brew install coreutils

## Usage on Linux

    ./build-debian.sh
or

    ./build-ubuntu.sh

This should do everything you need. If you don't have required package then:

    sudo apt-get install p7zip-full
    sudo apt-get install curl
    sudo apt-get install genisoimage
    sudo apt-get install coreutils

## Usage on Windows (under cygwin/git shell)

    ./build-debian.sh
or

    ./build-ubuntu.sh

Tested under Windows 7 with this tools:

 * [7zip](http://www.7-zip.org/)
 * [cpio](http://gnuwin32.sourceforge.net/packages/cpio.htm)
 * [mkisofs](http://sourceforge.net/projects/cdrtoolswin/)
 * [md5](http://www.fourmilab.ch/md5/)

## Environment variables

You can affect the default behaviour of the script using environment variables:

    VAR=value ./build.sh

The following variables are supported:

* `PRESEED` — path to custom preseed file. May be useful when if you need some customizations for your private base box (user name, passwords etc.);

* `LATE_CMD` — path to custom late_command.sh. May be useful when if you need some customizations for your private base box (user name, passwords etc.);

* `VM_GUI` — if set to `yes` or `1`, disables headless mode for vm. May be useful for debugging installer;


### Notes

This script basted on original dotzero's [repo](https://github.com/dotzero/vagrant-debian-wheezy-64) and with some tweaks to be compatible Debian/Ubuntu.
