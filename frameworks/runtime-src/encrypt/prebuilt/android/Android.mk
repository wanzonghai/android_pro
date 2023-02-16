LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := encrypt_static
LOCAL_MODULE_FILENAME := libencrypt
LOCAL_SRC_FILES := $(APP_ABI)/encrypt.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../../include
include $(PREBUILT_STATIC_LIBRARY)

