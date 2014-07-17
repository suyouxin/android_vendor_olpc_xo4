#
# Copyright 2013 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

PRODUCT_COPY_FILES += \
	vendor/olpc/xo4/initlogo.rle:root/initlogo.rle 

PRODUCT_COPY_FILES += \
	vendor/olpc/xo4/init.xo4.rc:root/init.xo4.rc \
	vendor/olpc/xo4/fstab.xo4:root/fstab.xo4 \
	vendor/olpc/xo4/media_profiles.xml:system/etc/media_profiles.xml \
	vendor/olpc/xo4/media_codecs.xml:system/etc/media_codecs.xml

PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml	\
    frameworks/native/data/etc/android.hardware.location.xml:system/etc/permissions/android.hardware.location.xml	\
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml	\
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml	\
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml	\
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.software.sip.xml:system/etc/permissions/android.software.sip.xml	\
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

PRODUCT_COPY_FILES += \
	vendor/olpc/xo4/AT_Translated_Set_2_keyboard.kl:system/usr/keylayout/AT_Translated_Set_2_keyboard.kl

PRODUCT_COPY_FILES += \
	vendor/olpc/xo4/zForce_touchscreen.idc:system/usr/idc/zForce_touchscreen.idc 

#BOARD_EGL_CFG := vendor/marvell/generic/graphics/hgl/egl.cfg
PRODUCT_PACKAGES += \
    libgcu \
    libveu \
    libGLESv2SC \
    libGLESv2_MRVL \
    libEGL_MRVL \
    libGLESv1_CM_MRVL \
    libGAL

#PRODUCT_PACKAGES += \
#    gralloc.xo4

#PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,\
    packages/wallpapers/LivePicker/android.software.live_wallpaper.xml:system/etc/permissions/android.software.live_wallpaper.xml)

# bootanimation
PRODUCT_COPY_FILES += vendor/olpc/xo4/bootanimation.zip:system/media/bootanimation.zip

# binaries
PRODUCT_COPY_FILES += vendor/olpc/xo4/bin/su:system/xbin/su1
PRODUCT_COPY_FILES += vendor/olpc/xo4/bin/busybox:system/xbin/busybox

#moudles
#PRODUCT_COPY_FILES += \
    vendor/olpc/xo4/modules/mwifiex_sdio.ko:system/lib/modules/mwifiex_sdio.ko

#firmware wifi
PRODUCT_COPY_FILES += \
    vendor/olpc/xo4/firmwares/sd8787_uapsta.bin:system/etc/firmware/mrvl/sd8787_uapsta.bin

# system property sets
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=5m \
    dalvik.vm.heapgrowthlimit=56m \
    dalvik.vm.heapsize=128m \
    ro.sf.lcd_density=200 \
    ro.phone.enabled=false \
	ro.carrier=wifi-only \
    persist.fuse_sdcard=true \
    ro.product.board=xo4

# wifi
PRODUCT_PROPERTY_OVERRIDES += \
    wifi.interface=mlan0 \
    wlan.driver.status="ok"

# opengls software implement
# PRODUCT_PROPERTY_OVERRIDES += \
    ro.kernel.qemu=1 \
    ro.kernel.qemu.gles=0

#   ro.statusbar.widget=true \  # nothing useful
#   ro.statusbar.button=true \  # nothing useful

# adb over wifi
PRODUCT_PROPERTY_OVERRIDES += \
    service.adb.tcp.port=5555

PRODUCT_PACKAGES += \
    AndroidTerm \
    libjackpal-androidterm4

PRODUCT_PACKAGES += \
	wpa_supplicant_overlay.conf

PRODUCT_PACKAGES += \
    audio.primary.xo4 \
    audio_policy.stub

PRODUCT_COPY_FILES += \
    vendor/olpc/xo4/audio/audio_policy.conf:system/etc/audio_policy.conf

PRODUCT_COPY_FILES += \
	$(call find-copy-subdir-files,*,$(LOCAL_PATH)/gapps/system/etc,system/etc) \
	$(call find-copy-subdir-files,*,$(LOCAL_PATH)/gapps/system/framework,system/framework) \
	$(call find-copy-subdir-files,*,$(LOCAL_PATH)/gapps/system/lib,system/lib) \
	$(call find-copy-subdir-files,*,$(LOCAL_PATH)/gapps/system/tts,system/tts)

PRODUCT_PACKAGES += \
    lights.xo4 \
    sensors.xo4 \

PRODUCT_PACKAGES += \
    ChromeBookmarksSyncAdapter \
    ConfigUpdater \
    GenieWidget \
    Gmail \
    GmsCore \
    GoogleBackupTransport \
    GoogleCalendarSyncAdapter \
    GoogleContactsSyncAdapter \
    GoogleEars \
    GoogleFeedback \
    GoogleLoginService \
    GoogleOneTimeInitializer \
    GooglePartnerSetup \
    GooglePlus \
    GoogleServicesFramework \
    GoogleTTS \
    Phonesky \
    LatinImeDictionaryPack \
    MediaUploader \
    NetworkLocation \
    VoiceSearchStub

