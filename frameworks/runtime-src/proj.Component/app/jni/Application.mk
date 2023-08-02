APP_ABI := armeabi-v7a
NDK_TOOLCHAIN_VERSION:=4.9
APP_STL := c++_static

LOCAL_SHORT_COMMANDS := true
APP_SHORT_COMMANDS := true

APP_CPPFLAGS := -frtti -DCC_ENABLE_CHIPMUNK_INTEGRATION=1 -std=c++11 -fsigned-char -pthread -fexceptions -Wno-literal-range 
APP_LDFLAGS := -latomic 


ifeq ($(NDK_DEBUG),1)
  APP_CPPFLAGS += -DCOCOS2D_DEBUG=1
  APP_CPPFLAGS += -D_DEBUG=1
  APP_OPTIM := debug
else
  APP_CPPFLAGS += -DNDEBUG
  APP_OPTIM := release
endif
APP_PLATFORM=android-21


ifeq ($(NDK_DEBUG),1)
   NDK_TOOLCHAIN_VERSION =clang
else
   NDK_TOOLCHAIN_VERSION =clang
endif


