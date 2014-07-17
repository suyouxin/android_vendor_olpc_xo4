#!/bin/sh
if [ "$#" -ne 1 ] ; then
    echo "$0: exactly 1 argument expected, needs usb dev name"
    exit 3
fi
usbvar=$1

echo "usb device is ${usbvar} ..."

sudo dd if=/dev/zero of=/dev/${usbvar}  bs=512  count=1

remote_script() {
cat <<EOSCRIPT
n
p


+20M
n
e



n
l

+400M

n
l

+300M

n
l


t
1
b
w
EOSCRIPT
}

remote_script | sudo fdisk /dev/${usbvar}
sudo fdisk -l /dev/${usbvar}

sudo umount /dev/${usbvar}1
sudo mkfs.vfat -n boot /dev/${usbvar}1

sudo umount /dev/${usbvar}5
sudo mkfs.ext4dev /dev/${usbvar}5
sudo tune2fs -L system /dev/${usbvar}5

sudo umount /dev/${usbvar}6
sudo mkfs.ext4dev /dev/${usbvar}6
sudo tune2fs -L cache /dev/${usbvar}6

sudo umount /dev/${usbvar}7
sudo mkfs.ext4dev /dev/${usbvar}7
sudo tune2fs -L data /dev/${usbvar}7




