\ syx.fth
: syx-boot-me
   " rw console=ttyS2,115200 console=tty0 selinux=0 fbcon=font:SUN12x22 fb_size=8M coherent_pool=64M loglevel=7 androidboot.hardware=xo4 rd.shell" expand$ to boot-file
   " u:\kernel"    expand$ to boot-device
   " u:\ramdisk" expand$ to ramdisk
   \ visible unfreeze
   boot
;

syx-boot-me
