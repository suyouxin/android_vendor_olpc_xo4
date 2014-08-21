\ syx.fth
: syx-boot-me
   " rw console=ttyS2,115200 console=tty0 selinux=0 fbcon=font:SUN12x22 fb_size=8M loglevel=7 androidboot.hardware=xo4 rd.shell" to boot-file
   " last:\kernel" to boot-device
   " last:\ramdisk" to ramdisk
   visible unfreeze
   boot
;

syx-boot-me
