#!/bin/bash 
if [ "$#" -ne 1 ] ; then
    echo "$0: exactly 1 argument expected, needs usb dev name"
    exit 3
fi

usbvar=$1

echo "${usbvar}"

echo "loading... boot to usb staick"
./mkboot.sh
sudo dd if=./boot.img of=/dev/${usbvar}1

echo "recreate data partition.."
sudo mkfs.ext4dev /dev/${usbvar}7
sudo tune2fs -L data /dev/${usbvar}7
echo "loading... system to usb staick"
simg2img ../../../../out/target/product/xo4/system.img system.img.raw
sudo dd if=./system.img.raw of=/dev/${usbvar}5 bs=4096
sudo tune2fs -L system /dev/${usbvar}5

sudo rm -rf system.img.raw
sudo rm -rf boot 
sudo rm -rf boot.img 
