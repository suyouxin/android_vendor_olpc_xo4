#!/bin/bash
set -e

mkdir -p imgs

echo "coping img from android build"
 
RELEASE=false
if [ "$1" == "release" ] ; then
    echo "build release images"
    RELEASE=true
fi

if [ $RELEASE == true ] ; then
    sudo rm -rf imgs/*
    sudo cp /home/android/run/out/dist/signed-img.zip imgs/
    sudo unzip imgs/signed-img.zip -d imgs/
    cd imgs/
    ../unmkbootimg -i boot.img
    sudo mv ramdisk.cpio.gz ramdisk.img
    cd ..
    sudo cp ../../../../out/target/product/xo4/userdata.tar.bz2 imgs/userdata.tar.bz2
else 
    sudo cp ../../../../out/target/product/xo4/kernel imgs/kernel
    sudo cp ../../../../out/target/product/xo4/ramdisk.img imgs/ramdisk.img
    sudo cp ../../../../out/target/product/xo4/system.img imgs/system.img
fi

# variable naming convention

# Z_ a .zd file
# I_ an image
# S_ a size in megabytes
# L_ a length in bytes
# O_ a starting offset in bytes
# E_ an ending offset in bytes
# D_ a loopback block device name

Z_INPUT=32013o4.zd # sugar install
I_INPUT=32013o4.img # sugar image

Z_OUTPUT=32013a4.zd

S_DEVICE=3775 # size of device in megabytes (XO-4 eMMC 4 GB)
S_SYSTEM=400 # size of system partition in megabytes
S_CACHE=300 # size of cache partition in megabytes

I_OUTPUT=${Z_OUTPUT/.zd/.img}

# check for missing files
[ ! -r imgs/kernel      ]  &&  echo missing kernel       &&  exit 1
[ ! -r imgs/ramdisk.img ]  &&  echo missing ramdisk.img  &&  exit 1
[ ! -r imgs/system.img  ]  &&  echo missing system.img   &&  exit 1
[ ! -r $Z_INPUT         ]  &&  echo missing $Z_INPUT     &&  exit 1

# undo existing loop devices we made
loop_release() {
    for file in loop.*; do
        if [[ $file = "loop.*" ]]; then break; fi
        sudo losetup -d /dev/${file/loop./} && rm -f $file
    done
}
loop_release

echo "$(basename $0): unpack input"

# extract the partition table of the sugar and gnome build
rm -f $I_INPUT
dd if=/dev/zero of=$I_INPUT bs=1024 count=0 seek=$(( $S_DEVICE * 1024 )) >/dev/null 2>/dev/null
./zdextract 0 1 < $Z_INPUT 1<> $I_INPUT 2>/dev/null

# locate offset and size of the two partitions
O_BOOT_INPUT=$(sudo parted -m $I_INPUT "unit B print"|grep '^1'|cut -f2 -d:|sed 's/B//g')
L_BOOT_INPUT=$(sudo parted -m $I_INPUT "unit B print"|grep '^1'|cut -f4 -d:|sed 's/B//g')
O_ROOT_INPUT=$(sudo parted -m $I_INPUT "unit B print"|grep '^2'|cut -f2 -d:|sed 's/B//g')
L_ROOT_INPUT=$(sudo parted -m $I_INPUT "unit B print"|grep '^2'|cut -f4 -d:|sed 's/B//g')
rm -f $I_INPUT

echo "$(basename $0): create output"

# position tracking
P=0

# allocate OLPC OS standard offset to first partition for compatibility
P=$(( $P + 4194304 ))

# firmware boot partition, two kernels
O_BOOT=$P
L_BOOT=$(( 71303168 + 23068672 - 1048576 )) # OLPC OS + Android Boot
E_BOOT=$(( $O_BOOT + $L_BOOT - 1 ))
P=$(( $P + $L_BOOT ))

# android system partition
O_SYSTEM=$P
L_SYSTEM=$(( $S_SYSTEM * 1024 * 1024 ))
E_SYSTEM=$(( $O_SYSTEM + $L_SYSTEM - 1 ))
P=$(( $P + $L_SYSTEM ))

# android cache partition
O_CACHE=$P
L_CACHE=$(( $S_CACHE * 1024 * 1024 ))
E_CACHE=$(( $O_CACHE + $L_CACHE - 1 ))
P=$(( $P + $L_CACHE ))

# root partition, Sugar and Gnome
O_ROOT=$P
L_ROOT=$(( $S_DEVICE * 1024 * 1024 - $O_ROOT )) # last block of disk
E_ROOT=$(( $O_ROOT + $L_ROOT - 1 ))
P=$(( $P + $L_ROOT ))

# create a sparse output image
rm -rf $I_OUTPUT
dd if=/dev/zero of=$I_OUTPUT bs=1024 count=0 seek=$(( $S_DEVICE * 1024 )) >/dev/null 2>/dev/null

# create partitions in the image
sudo parted --align none $I_OUTPUT <<EOF >/dev/null
unit b
mklabel msdos
mkpart primary ext2 ${O_BOOT}B ${E_BOOT}B
mkpart primary ext4 ${O_ROOT}B ${E_ROOT}B
mkpart primary ext4 ${O_SYSTEM}B ${E_SYSTEM}B
mkpart primary ext4 ${O_CACHE}B ${E_CACHE}B
quit
EOF

# make loop devices for the partitions
D_BOOT=$(sudo losetup --show --find --offset $O_BOOT --sizelimit $L_BOOT $I_OUTPUT)
touch loop.${D_BOOT/\/dev\//}
D_ROOT=$(sudo losetup --show --find --offset $O_ROOT --sizelimit $L_ROOT $I_OUTPUT)
touch loop.${D_ROOT/\/dev\//}
D_SYSTEM=$(sudo losetup --show --find --offset $O_SYSTEM --sizelimit $L_SYSTEM $I_OUTPUT)
touch loop.${D_SYSTEM/\/dev\//}
D_CACHE=$(sudo losetup --show --find --offset $O_CACHE --sizelimit $L_CACHE $I_OUTPUT)
touch loop.${D_CACHE/\/dev\//}

echo "$(basename $0): add sugar"

# sparse copy existing filesystems
# (needs root, using sudo results in error, as the redirects are
# processed before the command is given to sudo).
./zdextract \
    $(( $O_BOOT_INPUT / 131072 )) \
    $(( $L_BOOT_INPUT / 131072 )) \
        < $Z_INPUT 1<> $D_BOOT 2> /dev/null
./zdextract \
    $(( $O_ROOT_INPUT / 131072 )) \
    $(( $L_ROOT_INPUT / 131072 )) \
        < $Z_INPUT 1<> $D_ROOT 2> /dev/null

echo "$(basename $0): add to boot"

# add android build to boot filesystem
sudo rm -rf boot
mkdir boot
sudo mount $D_BOOT boot
sudo mkdir boot/boot/alt
sudo cp imgs/kernel boot/boot/alt/vmlinuz
sudo cp imgs/ramdisk.img boot/boot/alt/initrd.img
sudo cp olpc.fth boot/boot/alt/olpc.fth
sudo umount $D_BOOT
sudo rm -rf boot

echo "$(basename $0): add android system filesystem"

# sparse copy the system filesystem
sudo rm -rf system.new system.old system.tmp
sudo simg2img imgs/system.img system.tmp
D_SYSTEM_INPUT=$(sudo losetup --show --find system.tmp)
touch loop.${D_SYSTEM_INPUT/\/dev\//}
mkfs.ext4dev -q $D_SYSTEM
# TODO: resolve several filesystem attribute differences
mkdir system.new system.old
sudo mount -o ro $D_SYSTEM_INPUT system.old
sudo mount $D_SYSTEM system.new
rsync -a system.old/ system.new/
sudo umount $D_SYSTEM_INPUT
sudo umount $D_SYSTEM
sudo rm -rf system.new system.old system.tmp


echo "$(basename $0): add android cache filesystem"

# create the cache and data filesystems
sudo mkfs.ext4dev -q -L cache $D_CACHE

echo "$(basename $0): add android data filesystem mount point to sugar"

# create an "android" folder in sugar system for android (to use as data)
sudo rm -rf root
mkdir root
sudo mount $D_ROOT root
sudo resize2fs $D_ROOT
mkdir -p root/android
# check if we have android data tar ball
[ -r imgs/userdata.tar.bz2 ] && echo "add android user data!" && tar -xvjf imgs/userdata.tar.bz2 --strip 1 -C root/android
sudo umount $D_ROOT
sudo rm -rf root

# release the loop devices
loop_release

echo "$(basename $0): compress image"

# convert the image into format suitable for Open Firmware
./zhashfs 0x20000 sha256 $I_OUTPUT ${Z_OUTPUT/.zd/.zsp} ${Z_OUTPUT} >/dev/null

echo "$(basename $0): cleanup"

rm -f $I_OUTPUT

echo "$(basename $0): done ok"
