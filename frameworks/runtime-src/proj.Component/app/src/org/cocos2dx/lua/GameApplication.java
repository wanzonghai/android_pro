package org.cocos2dx.lua;

import android.app.Application;

import org.cocos2dx.lua.tools.ClassUtils;

public class GameApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        ClassUtils.initApplication(this);
    }
}
