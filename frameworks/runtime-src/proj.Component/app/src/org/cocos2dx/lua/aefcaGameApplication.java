package org.cocos2dx.lua;

import android.app.Application;

import org.cocos2dx.lua.tools.ClassUtils;

public class aefcaGameApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        ClassUtils.initApplication(this);
    }
}
