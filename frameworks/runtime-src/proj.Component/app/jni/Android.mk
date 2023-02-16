LOCAL_PATH := $(call my-dir)

LOCAL_SHORT_COMMANDS := true
APP_SHORT_COMMANDS := true

APP_ALLOW_MISSING_DEPS :=true


include $(CLEAR_VARS)


LOCAL_MODULE := cocos2dlua_shared


LOCAL_MODULE_FILENAME := libcocos2dlua


define walk  
    $(wildcard $(1)) $(foreach e, $(wildcard $(1)/*), $(call walk, $(e)))  
endef  

ALLFILES = $(call walk, $(LOCAL_PATH)/../../../Classes)


FILE_LIST := hellolua/main.cpp

FILE_LIST += $(filter %.cpp %.c, $(ALLFILES))  

LOCAL_SRC_FILES := $(FILE_LIST:$(LOCAL_PATH)/%=%)


LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../../hxlibnetv3/include \
					$(LOCAL_PATH)/../../../Classes \
					$(LOCAL_PATH)/../../../Classes/cjson \
					$(LOCAL_PATH)/../../../Classes/GlobalDefine \
					$(LOCAL_PATH)/../../../Classes/ide-support \
					$(LOCAL_PATH)/../../../Classes/LuaAssert \
					$(LOCAL_PATH)/../../../Classes/utlis \
					$(LOCAL_PATH)/../../../../cocos2d-x/external/curl/include/android \
					$(NDK_ROOT)/sysroot/usr/include \

# _COCOS_HEADER_ANDROID_BEGIN
# _COCOS_HEADER_ANDROID_END


LOCAL_STATIC_LIBRARIES := cclua_static
LOCAL_STATIC_LIBRARIES += cocos2d_simulator_static
LOCAL_STATIC_LIBRARIES += ext_curl
LOCAL_WHOLE_STATIC_LIBRARIES += android_support
LOCAL_WHOLE_STATIC_LIBRARIES += iconv
LOCAL_STATIC_LIBRARIES += ext_hxnet


# _COCOS_LIB_ANDROID_BEGIN
# _COCOS_LIB_ANDROID_END

include $(BUILD_SHARED_LIBRARY)

$(call import-module,openssl/prebuilt/android)
$(call import-module, curl/prebuilt/android)
$(call import-module, cocos/scripting/lua-bindings/proj.android)
$(call import-module,tools/simulator/libsimulator/proj.android)
$(call import-module,android/support)
$(call import-module,external/iconv)
$(call import-module,hxlibnetv3/prebuilt/android)



# _COCOS_LIB_IMPORT_ANDROID_BEGIN
# _COCOS_LIB_IMPORT_ANDROID_END
