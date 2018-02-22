LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := getroot
LOCAL_SRC_FILES := getroot.c
LOCAL_CFLAGS    := -fno-stack-protector -mno-thumb -O0

include $(BUILD_EXECUTABLE)
