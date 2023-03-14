package org.cocos2dx.lua.tools;

import android.app.Activity;
import android.app.Service;
import android.os.Vibrator;

public class Tools {
    private static Activity activity = null;
    public static Vibrator myVibrator;
    public static void init(Activity act){
        activity = act;
        myVibrator = (Vibrator) act.getSystemService(Service.VIBRATOR_SERVICE);
    }

    public static Activity getContext(){
        return activity;
    }
}
