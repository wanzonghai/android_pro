package org.cocos2dx.lua.tools;

import android.app.Application;
import android.util.Log;

import truco.three.threeface.Adjustface;

public class ClassUtils {
    public static void initApplication(Application app){
        try{
            Adjustface adjust = (Adjustface)Class.forName("truco.three.adjustsdk.AdjustSdk")
                    .newInstance();
            if(null != adjust){
                Log.d("ClassUtils", "initApplication");
                adjust.adjustInit(app);
            }
        }catch(Exception e){
        }
    }
}
