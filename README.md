## About

This script will:

 1. download the last 'STABLE' version `Debian` or last `Ubuntu` server iso ( 64 or 32 bit )
 2. do some magic to turn it into a vagrant box file
 3. output `debian/debian-{VERSION}-{ARCH}.box` or `ubuntu/ubuntu-{VERSION}-{ARCH}.box`
 4. add just created vagrant box to available list

## Requirements

 * Oracle VM VirtualBox
 * Vagrant
 * 7zip
 * curl
 * mkisofs/genisoimage
 * md5sum/md5

## Usage on OSX

    ./build-debian.sh <32|64> 
or

    ./build-ubuntu.sh <32|64> [lts]

This should do everything you need. If you don't have required package, install [homebrew](http://mxcl.github.com/homebrew/), then:

    brew install p7zip
    brew install curl
    brew install cdrtools
    brew install coreutils

## Usage on Linux

    ./build-debian.sh <32|64> 
or

    ./build-ubuntu.sh <32|64> [lts]

This should do everything you need. If you don't have required package then:

    sudo apt-get install p7zip-full
    sudo apt-get install curl
    sudo apt-get install genisoimage
    sudo apt-get install coreutils

## Usage on Windows (under cygwin/git shell)

    ./build-debian.sh <32|64> 
or

    ./build-ubuntu.sh <32|64> [lts]

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

* `HDD_SIZE` — size of hdd image in Mbytes. Default value = 51200 ( = 50GB )

### Notes

This script basted on 
 * kraksoft [repo](https://github.com/kraksoft/vagrant-box)
 * dotzero's [repo](https://github.com/dotzero/vagrant-debian-wheezy-64)
 * tiwilliam [repo](https://github.com/tiwilliam/vagrant-debian)
