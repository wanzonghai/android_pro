package org.cocos2dx.lua;

import android.app.Application;
import android.util.Log;

import org.cocos2dx.lua.tools.ClassUtils;
import org.cocos2dx.lua.tools.PTools;

public class GameApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        Log.d("GameApplication", "onCreate 1");
        ClassUtils.initApplication(this);
        Log.d("GameApplication", "onCreate 2");
        PTools.pa_app_init(this);
    }
}
