#!/bin/sh
set -e 

function usage {
	echo " ";
	echo "usage: ";
	echo " . build_release.sh [KEYS_PATH]";
	echo " ";
	echo "example: ";
	echo " . build_release.sh vendor/olpc/security/xo4";
	echo " ";
	echo "see how to create keys ";
	echo "   http://www.kandroid.org/online-pdk/guide/release_keys.html"
	echo " ";
	echo " ";
	exit 1;
}

if test $# -ne 1; then
	usage
fi

KEYS_PATH=$1

TOOLS_PATH=./build/tools/releasetools
OUT_PATH=./out/dist

RELEASE_TAR_BALL=full_xo4-target_files-eng.android.zip
RELEASE_TAR_BALL_SIGNED=full_xo4-target_files-eng.android-signed.zip
RELEASE_IMGS=signed-img.zip

cd ../../../../ && . build/envsetup.sh

choosecombo 1 full_xo4 1

make installclean && make -j16 dist && make userdatatarball
# sign zip file with release keys
$TOOLS_PATH/sign_target_files_apks -d $KEYS_PATH $OUT_PATH/$RELEASE_TAR_BALL $OUT_PATH/$RELEASE_TAR_BALL_SIGNED
# convert tar ball to images
$TOOLS_PATH/img_from_target_files $OUT_PATH/$RELEASE_TAR_BALL_SIGNED $OUT_PATH/$RELEASE_IMGS

cd vendor/olpc/xo4/sugar-combiner && sudo ./mkzd.sh release

rm -rf output && mkdir -p output && for N in imgs/32014a4.zd imgs/kernel imgs/ramdisk.img imgs/system.img imgs/userdata.tar.bz2; do md5sum $N > ./output/$(basename $N).md5; ln -s ../$N ./output/$(basename $N);  done



