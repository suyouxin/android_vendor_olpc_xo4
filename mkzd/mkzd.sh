#!/bin/bash
set -e

out_folder="out/target/product/xo4"

userdata=../../../../$out_folder/userdata.tar.bz2

# undo existing loop devices we made
loop_release() {
    for file in loop.*; do
	if [[ $file = "loop.*" ]]; then break; fi
	echo release $file
	sudo losetup -d /dev/${file/loop./} && rm -f $file
    done
}
loop_release

SIZE=3801088
# create a sparse image
IMAGE=syx.img
rm -rf $IMAGE
dd if=/dev/zero of=$IMAGE bs=1024 count=0 seek=$SIZE >/dev/null 2>/dev/null

# partition the image
sudo parted $IMAGE <<EOF
mklabel msdos
mkpart primary ext2 1048576B 22020095B
mkpart primary ext4 759169024B 3892314111B
mkpart primary ext4 23068672B 547356672B
mkpart primary ext4 548405248B 758120447B
quit
EOF

# grab the offsets from the partition table
P1=$(sudo parted -m $IMAGE "unit B print"|grep '^1'|cut -f2 -d:|sed 's/B//g')
S1=$(sudo parted -m $IMAGE "unit B print"|grep '^1'|cut -f4 -d:|sed 's/B//g')
P2=$(sudo parted -m $IMAGE "unit B print"|grep '^2'|cut -f2 -d:|sed 's/B//g')
S2=$(sudo parted -m $IMAGE "unit B print"|grep '^2'|cut -f4 -d:|sed 's/B//g')
P3=$(sudo parted -m $IMAGE "unit B print"|grep '^3'|cut -f2 -d:|sed 's/B//g')
S3=$(sudo parted -m $IMAGE "unit B print"|grep '^3'|cut -f4 -d:|sed 's/B//g')
P4=$(sudo parted -m $IMAGE "unit B print"|grep '^4'|cut -f2 -d:|sed 's/B//g')
S4=$(sudo parted -m $IMAGE "unit B print"|grep '^4'|cut -f4 -d:|sed 's/B//g')

# make loop devices for the partitions
L1=$(sudo losetup --show --find --offset $P1 --sizelimit $S1 $IMAGE)
touch loop.${L1/\/dev\//}
L2=$(sudo losetup --show --find --offset $P2 --sizelimit $S2 $IMAGE)
touch loop.${L2/\/dev\//}
L3=$(sudo losetup --show --find --offset $P3 --sizelimit $S3 $IMAGE)
touch loop.${L3/\/dev\//}
L4=$(sudo losetup --show --find --offset $P4 --sizelimit $S4 $IMAGE)
touch loop.${L4/\/dev\//}

# create the boot filesystem
echo "loading... boot/"
sudo mkfs.ext2 -q -O dir_index,^resize_inode -L boot -F $L1
sudo rm -rf boot
mkdir boot
sudo mount $L1 boot
sudo cp ../../../../$out_folder/kernel boot/
sudo cp ../../../../$out_folder/ramdisk.img boot/ramdisk
sudo mkdir boot/boot
sudo cp quiet.fth boot/boot/olpc.fth
sudo umount $L1
sudo rm -rf boot

# copy the system filesystem
echo "loading... system/"
sudo simg2img ../../../../$out_folder/system.img $L3

# create the cache and data filesystems
sudo mkfs.ext4dev -q -L cache $L4
sudo mkfs.ext4dev -q -L data $L2

# create an "android" folder in sugar system for android (to use as data)
sudo rm -rf root
mkdir root
sudo mount $L2 root
sudo resize2fs $L2
mkdir -p root/android
# check if we have android data tar ball
[ -r $userdata ] && echo "add android user data!" && tar -xvjf $userdata --strip 1 -C root/android
sudo umount $L2
sudo rm -rf root

# release the loop devices
loop_release

# convert the image into format suitable for Open Firmware
./zhashfs 0x20000 sha256 $IMAGE syx.zsp syx.zd

rm -f $IMAGE
