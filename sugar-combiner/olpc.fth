\ OLPC dual-boot script

: show-android  ( -- )
   android.icon icon>pixels             ( pixels )
   d# 1200 2/ icon-size 2/ -            ( pixels x )
   d# 900  2/ icon-size 2/ -            ( pixels x y )
   icon-size dup                        ( pixels x y w h )
   " draw-rectangle" $call-screen       ( )
;

: boot-android  ( -- )
   cursor-off blank-screen show-android invisible
   " last:\boot-alt\vmlinuz" to boot-device
   " last:\boot-alt\initrd.img" to ramdisk
   boot
;

boot-android
