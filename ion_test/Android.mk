LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)

#LOCAL_CFLAGS += -DHAVE_CONFIG_H 

LOCAL_SRC_FILES:=ionsyx.c

LOCAL_PRELINK_MODULE := false

LOCAL_MODULE_TAGS := optional
LOCAL_MODULE:= ionsyx

LOCAL_SHARED_LIBRARIES := liblog libcutils libion_pxa
include $(BUILD_EXECUTABLE)



