#!/bin/bash 

echo "making ramdisk.img..."
#find ~/xo-laptop/initrd/initramfs -print | cpio -H newc -o | gzip -9 >./ramdisk.img
#sudo cp -rp ramdisk.img /media/boot/ && sync

usbvar=sdc
#usbvar=$1

echo "${usbvar}"

echo "loading... system to usb staick"
cp ~/android-src/4.3.1/out/target/product/xo4/system.img ./
simg2img system.img system.img.raw
sudo dd if=./system.img.raw of=/dev/${usbvar}5 bs=4096
sudo tune2fs -L system /dev/${usbvar}5

