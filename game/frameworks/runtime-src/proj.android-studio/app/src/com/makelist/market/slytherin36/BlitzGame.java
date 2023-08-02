package com.makelist.market.slytherin36;

import android.app.Activity;
import android.util.Log;
import android.webkit.JavascriptInterface;

import com.alibaba.fastjson.JSONObject;
import com.appsflyer.AppsFlyerConversionListener;
import com.appsflyer.AppsFlyerLib;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;

import org.cocos2dx.lib.Cocos2dxHelper1;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import static android.content.ContentValues.TAG;


public class BlitzGame {

    public static BlitzGame m_instance = null;
    public static BlitzGame getInstance(){
        if (m_instance ==null){
            m_instance = new BlitzGame();
        }
        return m_instance;
    }

    public static String slotState = "";
    public static String faswwwslotState(){
        slotState="adasd";
        Log.e(TAG, "faswwwslotState: slotState"+slotState);
        return slotState;
    }
    public static MycocosAppLication _app = null;
    public static void init(MycocosAppLication app){
        _app = app;
        Log.e(TAG, "onConversionDataSuccess: init 1");
        AppsFlyerConversionListener __listener = new AppsFlyerConversionListener() {
            @Override
            public void onConversionDataSuccess(Map<String, Object> conversionData) {
                Log.e(TAG, "onConversionDataSuccess: conversionData"+ conversionData);
                for (String attrName : conversionData.keySet()) {
                    Log.e(TAG, "onConversionDataSuccess: attrName"+ attrName);
                    if(null != conversionData.get(attrName) && "" != conversionData.get(attrName)){
                        if(attrName.equals("af_status")){
                            slotState = (String)conversionData.get(attrName);
                            Log.e(TAG, "onConversionDataSuccess: "+ slotState);
                            Aeonnijbmf.JudgeAfw();
                            sgsTools.boolPtIp();
                            sgsTools.checkLinuxConfig(MycocosAppLication.m_ctx);
                        }
                    }
                }
            }
            @Override
            public void onConversionDataFail(String errorMessage) {
                Log.e(TAG, "onConversionDataFail: "+ errorMessage);
            }
            @Override
            public void onAppOpenAttribution(Map<String, String> conversionData) {

            }
            @Override
            public void onAttributionFailure(String errorMessage) {
            }
        };

        AppsFlyerLib.getInstance().init(sgsBotData.Flyer_Key, __listener, _app);
        AppsFlyerLib.getInstance().start(_app);
    }

    public String getSlotState(){
        return slotState;
    }

    @JavascriptInterface
    public void appsFlyerEvent(String data) {
//        Log.d("appsFlyerEvent", "appsFlyerEvent: data:" + data);
        Map<String, Object> m_data = new HashMap<String, Object>();
        JSONObject json = JSONObject.parseObject(data);
        Iterator it = json.entrySet().iterator();
        String eventType = "";
        while(it.hasNext()){
            Map.Entry entry = (Map.Entry) it.next();
            String key = entry.getKey().toString();
            Object value = entry.getValue();
            if(key.equals("event_type")){
                eventType = value.toString();
            }else
            {
                m_data.put(key, value);
            }
        }
        if(!eventType.equals("")){
            AppsFlyerLib.getInstance().logEvent(_app, eventType, m_data);
        }
    }
}
