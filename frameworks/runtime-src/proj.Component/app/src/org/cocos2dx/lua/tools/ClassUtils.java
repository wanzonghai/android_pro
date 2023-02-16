package org.cocos2dx.lua.tools;

import android.app.Activity;
import android.app.Application;

import truco.three.threeface.Adjustface;
import truco.three.threeface.FireBaseInterface;
import truco.three.threeface.FirebaseMessageface;

public class ClassUtils {
    public static void initApplication(Application app){
        try{
            Adjustface adjust = (Adjustface)Class.forName("truco.three.adjustsdk.AdjustSdk")
                    .newInstance();
            if(null != adjust){
                adjust.adjustInit(app);
            }
        }catch(Exception e){
        }
    }

    public static void initActivity(final Activity act){
        try{
            FireBaseInterface fireBaseSDK = (FireBaseInterface) Class.forName("truco.three.firebasesdk.FireBaseSDK")
                    .newInstance();
            if(null != fireBaseSDK){
                fireBaseSDK.initSDK(act);
            }
        }catch(Exception e){
        }

        try{
            FirebaseMessageface messageInterface = (FirebaseMessageface)Class.forName("truco.three.firebasesdk.MyFirebaseMessagingService")
                    .newInstance();
            if(null != messageInterface){
                messageInterface.initSDK(act);
            }
        }catch (Exception e){
        }
    }
}
