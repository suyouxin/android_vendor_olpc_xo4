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

# boot animation
PRODUCT_COPY_FILES += \
    vendor/olpc/xo4/initlogo.rle:root/initlogo.rle \
    vendor/olpc/xo4/bootanimation.zip:system/media/bootanimation.zip \

PRODUCT_COPY_FILES += \
	vendor/olpc/xo4/init.xo4.rc:root/init.xo4.rc \
	vendor/olpc/xo4/ueventd.xo4.rc:root/ueventd.xo4.rc \
	vendor/olpc/xo4/media_profiles.xml:system/etc/media_profiles.xml \
	vendor/olpc/xo4/media_codecs.xml:system/etc/media_codecs.xml \
	vendor/olpc/xo4/powerhal.conf:system/etc/powerhal.conf
#	vendor/olpc/xo4/camera_profiles.xml:system/etc/camera_profiles.xml \

# file system configure table
PRODUCT_COPY_FILES += \
	vendor/olpc/xo4/fstab_sugar.xo4:root/fstab.xo4 

# permissions that we supported
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/tablet_core_hardware.xml:system/etc/permissions/tablet_core_hardware.xml	\
    frameworks/native/data/etc/android.hardware.location.xml:system/etc/permissions/android.hardware.location.xml	\
    frameworks/native/data/etc/android.hardware.touchscreen.multitouch.jazzhand.xml:system/etc/permissions/android.hardware.touchscreen.multitouch.jazzhand.xml	\
    frameworks/native/data/etc/android.hardware.usb.accessory.xml:system/etc/permissions/android.hardware.usb.accessory.xml	\
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml	\
    frameworks/native/data/etc/android.hardware.sensor.accelerometer.xml:system/etc/permissions/android.hardware.sensor.accelerometer.xml \
    frameworks/native/data/etc/android.software.sip.xml:system/etc/permissions/android.software.sip.xml	\
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml \
    frameworks/native/data/etc/android.hardware.camera.xml:system/etc/permissions/android.hardware.camera.xml \
    frameworks/native/data/etc/android.hardware.camera.front.xml:system/etc/permissions/android.hardware.camera.front.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    frameworks/native/data/etc/android.hardware.bluetooth.xml:system/etc/permissions/android.hardware.bluetooth.xml \
    frameworks/native/data/etc/android.hardware.bluetooth_le.xml:system/etc/permissions/android.hardware.bluetooth_le.xml

# frameworks/native/data/etc/android.hardware.wifi.direct.xml:system/etc/permissions/android.hardware.wifi.direct.xml \

PRODUCT_COPY_FILES += $(call add-to-product-copy-files-if-exists,\
    packages/wallpapers/LivePicker/android.software.live_wallpaper.xml:system/etc/permissions/android.software.live_wallpaper.xml)

# GPU: for new driver version
PRODUCT_PACKAGES += \
    libGLESv1_CM_MRVL \
    libGLESv2_MRVL \
    libEGL_MRVL \
    libGLESv2 \
    libGLESv2SC \
    gfx.cfg

# special binaries
PRODUCT_PACKAGES += \
    e2fsck \
    resize2fs \
    sfdisk \
    busybox 

# system property sets
PRODUCT_PROPERTY_OVERRIDES += \
    dalvik.vm.heapstartsize=5m \
    dalvik.vm.heapgrowthlimit=48m \
    dalvik.vm.heapsize=192m \
    ro.sf.lcd_density=200 \
    ro.phone.enabled=false \
	ro.carrier=wifi-only \
    persist.fuse_sdcard=true \
    ro.product.board=xo4 \
    persist.sys.mrvl_wl_recovery=0 \
    persist.service.camera.cnt=1 \
    persist.sys.country=US \
    persist.sys.language=en \
    persist.sys.timezone=Pacific/Auckland

# file system resize
PRODUCT_COPY_FILES += \
    vendor/olpc/xo4/olpc-filesystem-resize.sh:root/sbin/olpc-filesystem-resize.sh \
    vendor/olpc/xo4/olpc-partition-resize.sh:root/sbin/olpc-partition-resize.sh

# set default keyboard layout to OLPC_Spanish
PRODUCT_COPY_FILES += \
    vendor/olpc/xo4/input-manager-state.xml:/data/system/input-manager-state.xml

# wifi
# PRODUCT_PROPERTY_OVERRIDES += \
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
    libwpa_client \
    hostapd \
    dhcpcd.conf \
    wpa_supplicant \
    wpa_supplicant.conf

PRODUCT_PACKAGES += \
    audio.primary.xo4 \
    audio_policy.stub

PRODUCT_COPY_FILES += \
    vendor/olpc/xo4/audio/audio_policy.conf:system/etc/audio_policy.conf

# light senser / accelerometer senser / power HAL
PRODUCT_PACKAGES += \
    lights.xo4 \
    sensors.xo4 \
    power.xo4 

# camera HAL
# PRODUCT_PACKAGES += \
    camera.xo4 \
    libion_mmp \
    libjpeg \
    libexif 

# Marvell wireless daemon
PRODUCT_PACKAGES += \
    MarvellWirelessDaemon \
    libMarvellWireless \
    rfkill \

# Wifi extention tools
PRODUCT_PACKAGES += \
	iperf \
	wireless_tool \
	iwconfig \
	iwlist \
	iwpriv \
	iwspy \
	iwgetid \
	iwevent \
	ifrename \
	macadd \
	WapiCertMgmt \
	simal \

# Bluetooth
PRODUCT_PACKAGES += \
	sdptool \
	hciconfig \
	hcitool \
	l2ping \
	hciattach \
	rfcomm \
	avinfo \

PRODUCT_PACKAGES += \
	AnTuTu

# Morphoss special 
PRODUCT_PACKAGES += \
    Terminal \
    libjackpal-androidterm4 \
    AdobeAir \
    XOFiles 

# GPU: alloc
BOARD_EGL_CFG := vendor/olpc/xo4/egl.cfg
PRODUCT_PACKAGES += \
    gralloc.xo4 \

# HWC HAL
PRODUCT_PACKAGES += \
    hwcomposer.xo4 \
    libHWComposerGC

# power settings modules
# PRODUCT_PACKAGES += \
    PowerSetting \
    libPowerSetting

# multimedia modules except gst, include IPP, bmm/pmem, opencore...
PRODUCT_PACKAGES += \
    libstagefrighthw  \
    libvmeta \
    libI420colorconvert

# recovery
PRODUCT_PACKAGES += \
    librecovery_ui_xo4

#$(call inherit-product-if-exists, vendor/marvell/generic/gpu-engine/gpuengine_modules.mk)
$(call inherit-product-if-exists, vendor/marvell/generic/ipplib/ipplib_modules.mk)
$(call inherit-product-if-exists, vendor/marvell/generic/phycontmem-lib/modules.mk)
$(call inherit-product-if-exists, vendor/marvell/generic/sd8787/FwImage/sd8787fw.mk)
$(call inherit-product-if-exists, vendor/olpc/xo4/gapps/gapps.mk)
$(call inherit-product-if-exists, vendor/olpc/xo4/uruguay/uruguay.mk)
$(call inherit-product-if-exists, vendor/olpc/xo4/keyboard/keyboard.mk)
$(call inherit-product-if-exists, vendor/olpc/xo4/touch/touch.mk)

# $(call inherit-product-if-exists, vendor/olpc/xo4/etc/etc.mk)
# $(call inherit-product-if-exists, vendor/marvell/generic/cpufreqd/cpufreq_modules.mk)
# $(call inherit-product-if-exists, vendor/marvell/generic/wfd_platform/wfd_modules.mk)
# $(call inherit-product-if-exists, vendor/marvell/generic/gst_modules.mk)
# $(call inherit-product-if-exists, vendor/marvell/generic/gst-plugins-marvell/gstpluginsmarvell_modules.mk)



