#!/bin/bash 

usbvar=$1

echo "${usbvar}"

sudo rm -rf ./boot
sudo rm -rf ./boot.img

sudo dd if=/dev/zero of=boot.img bs=20971520 count=1
sudo mkfs.vfat -n boot boot.img
mkdir boot
sudo mount -t vfat boot.img ./boot
sudo cp ../../../../out/target/product/xo4/kernel ./boot/
sudo cp ../../../../out/target/product/xo4/ramdisk.img ./boot/ramdisk
sudo cp quiet.fth ./boot/
sudo umount ./boot.img
