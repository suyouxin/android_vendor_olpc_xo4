#!/sbin/busybox sh
# Copyright (C) 2009 One Laptop per Child
# Licensed under the GPLv2
#
should_resize_partition() {
    local part_end=$(/sbin/sfdisk -l -uB -H 4 -S 32 /dev/block/mmcblk0 | /sbin/busybox grep "0p2" | /sbin/busybox awk -F" " '{print $3}')
	local disk_size=$(/sbin/sfdisk -s -uB -H 4 -S 32 /dev/block/mmcblk0)

	echo "Dsize $disk_size Pend $part_end" > /dev/kmsg

	[ "$((part_end + 1))" = "$disk_size" ] && return 1
	echo "Disk should be resized." > /dev/kmsg
	return 0
}

resize_partition()
{
	local sys_part="mmcblk0p2"
	local sys_disk=${sys_part%p?}
	local partnum=2

	local disk_size=$(/sbin/sfdisk -s -uB -H 4 -S 32 /dev/block/$sys_disk)
    local part_start=$(/sbin/sfdisk -l -uB -H 4 -S 32 /dev/block/$sys_disk | /sbin/busybox grep "0p2" | /sbin/busybox awk -F" " '{print $2}')
	local part_size=$((disk_size - part_start))

	# udev might still be busy probing the disk, meaning that it will be in
	# use. Give it a chance to finish first.
    # udevadm settle

	echo "Try resize: $part_start $part_sizes fdisk -N$partnum -uB -S 32 -H 4 /dev/block/$sys_disk" > /dev/kmsg
	echo "$part_start $part_size" | /sbin/sfdisk --force -N$partnum -uB -S 32 -H 4 /dev/block/$sys_disk &>/dev/kmsg
	echo "sfdisk returned $?" > /dev/kmsg

	# Partition nodes are removed and recreated now - wait for udev to finish
	# recreating them before trying to re-mount the disk.
 	# udevadm settle
    typeset -i mCnt=0
    while [[ ${mCnt} -le 1000000 ]]; do
    mCnt=${mCnt}+1
    done
}

echo "check resize partition..." > /dev/kmsg
if should_resize_partition; then
    echo "will attempt resize partition" > /dev/kmsg
    resize_partition
fi
