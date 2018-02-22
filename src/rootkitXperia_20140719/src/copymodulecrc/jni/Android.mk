LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := copymodulecrc
LOCAL_SRC_FILES := copymodulecrc.c

include $(BUILD_EXECUTABLE)
