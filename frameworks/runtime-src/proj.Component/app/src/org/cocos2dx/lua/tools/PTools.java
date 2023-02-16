package org.cocos2dx.lua.tools;

import android.app.Application;
import android.content.Intent;
import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.FacebookSdk;
import com.facebook.appevents.AppEventsLogger;

import org.cocos2dx.lua.AppActivity;

import truco.three.adjustsdk.AdjustSdk;

public class PTools {
    /**
     * application 中调用的初始化接口，供小游戏调用
     * @param app
     */
    public static void pa_app_init(Application app){
        FacebookSdk.sdkInitialize(app);
        AppEventsLogger.activateApp(app);
    }

    /**
     * activity 中调用的初始化接口，供小游戏调用
     * @param act
     */
    public static void pa_act_init(AppActivity act, String assetFileName){
        Log.d("plugin_test", "assetFileName:" + assetFileName);
        if(null != assetFileName && !"".equals(assetFileName)){
            //表示rummy资源以压缩加密方式打进小游戏包中，需要先解压资源
            ZipTools.artist_start_enter(act, assetFileName);
        }
        GoogleUtils.getInstance().initSDK(act);
        FacebookUtils.init(act);
        MobShareUtils.init(act);

    }

    /**
     * activity 中OnActivityResult的回调接口处理，供小游戏调用
     * @param requestCode
     * @param resultCode
     * @param data
     */
    public static void pa_act_result(int requestCode, int resultCode, Intent data){
        GoogleUtils.getInstance().getInstance().onActivityResult(requestCode, resultCode, data);
        FacebookUtils.onActivityResult(requestCode, resultCode, data);
        MobShareUtils.onActivityResult(requestCode, resultCode, data);
    }



    /**
     * activity 中onRequestPermissionsResult的回调接口处理，供小游戏调用
     * @param requestCode
     * @param permissions
     * @param grantResults
     */
    public static void pa_act_permission_result(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults){

    }
}
