#!/system/bin/sh
# Copyright (C) 2009 One Laptop per Child
# Licensed under the GPLv2
#

first_time_boot() {
#   return 1
#   need found another way to test if it first time, this does not work
    if [[ -n $(/system/bin/getprop | /system/bin/grep ro.runtime.firstboot) ]]; then 
        echo "not first time" > /dev/kmsg && return 0
    else 
        echo "first time" > /dev/kmsg && return 1
    fi
}

resize_filesystem() {
    busybox mount -t ext4 /dev/block/mmcblk0p3 /system
#   if first_time_boot; then busybox umount /system && return 1; fi
	echo "Growing data filesystem (if it can be grown)" > /dev/kmsg
	local syspart="/dev/block/mmcblk0p2"
	echo ",+,," | /system/bin/e2fsck -fy "$syspart" &>/dev/kmsg
	echo "e2fsck returned $?" > /dev/kmsg
	echo ",+,," | /system/bin/resize2fs "$syspart" &>/dev/kmsg
	echo "resize2fs returned $?" > /dev/kmsg
    busybox umount /system
}

echo "resize filesystem..." > /dev/kmsg
resize_filesystem
