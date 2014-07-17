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

TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
TARGET_NO_RECOVERY := true

BOARD_HAVE_BLUETOOTH := false

WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211

BOARD_WLAN_DEVICE := qcwcn 
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
# BOARD_WLAN_DEVICE := mrvl
#BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_mrvl
#WIFI_DRIVER_MODULE_PATH := "/system/lib/modules/mwifiex_sdio.ko"
#WIFI_DRIVER_MODULE_NAME := "mwifiex_sdio"

BOARD_USES_GENERIC_AUDIO := true
TARGET_HARDWARE_3D := false

# no hardware camera
USE_CAMERA_STUB := false

# Enable dex-preoptimization to speed up the first boot sequence
# of an SDK AVD. Note that this operation only works on Linux for now
ifeq ($(HOST_OS),linux)
  ifeq ($(WITH_DEXPREOPT),)
    WITH_DEXPREOPT := true
  endif
endif

# Build OpenGLES emulation guest and host libraries
BUILD_EMULATOR_OPENGL := false

# Build and enable the OpenGL ES View renderer. When running on the emulator,
# the GLES renderer disables itself if host GL acceleration isn't available.
USE_OPENGL_RENDERER := true

BOARD_ENABLE_MULTI_DISPLAYS := true

# system.img setting
TARGET_USERIMAGES_USE_EXT4 := true
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 367001600
BOARD_FLASH_BLOCK_SIZE := 4096
# boot.img setting
TARGET_BOOTIMAGE_USE_EXT2 := true
BOARD_BOOTIMAGE_MAX_SIZE := 8388608

DEVICE_PACKAGE_OVERLAYS := vendor/olpc/xo4/overlay

#PRODUCT_AAPT_CONFIG := normal hdpi xhdpi
PRODUCT_AAPT_PREF_CONFIG := hdpi

# The above lines are almost the same as Brownstone.
# MMP3 Special
TARGET_CPU_SMP := true
BOARD_USE_VIVANTE_GRALLOC := true
HDMI_SUPPORT_3D := true

BOARD_GFX_DRIVER_VERSION=4x

#DYNAMIC_ALSA_PARAMS := true

#Enable marvell interface in SurfaceFlinger
MRVL_INTERFACE_ANIMATION := true
ENABLE_HWC_GC_PATH := true

#Launch DMS in SurfaceFlinger process
MRVL_LAUNCH_DMS_IN_SURFACEFLINGER := true
BOARD_USES_GENERIC_AUDIO := false
BOARD_USES_ALSA_AUDIO := true
BUILD_WITH_ALSA_UTILS := true
BOARD_DEFAULT_SAMPLE_RATE := 48000
AUDIO_USES_48K := true
