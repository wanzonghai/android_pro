package truco.three.adjustsdk;

import android.app.Activity;
import android.app.Application;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import com.adjust.sdk.Adjust;
import com.adjust.sdk.AdjustAttribution;
import com.adjust.sdk.AdjustConfig;
import com.adjust.sdk.AdjustEvent;
import com.adjust.sdk.LogLevel;
import com.adjust.sdk.OnAttributionChangedListener;
import com.alibaba.fastjson.JSONObject;
import com.game.brazil.R;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import truco.three.threeface.Adjustface;

public class AdjustSdk implements Adjustface {
    private static Context m_ctx = null;
    private static String m_status = "";

    @Override
    public void adjustInit(Application context) {
        m_ctx = context;
        String _apptoken = context.getResources().getString(R.string.adjust_key);
        //AdjustConfig.ENVIRONMENT_PRODUCTION 生产环境 AdjustConfig.ENVIRONMENT_SANDBOX 测试开发环境
        String environment = AdjustConfig.ENVIRONMENT_PRODUCTION;
        AdjustConfig config = new AdjustConfig(context, _apptoken, environment);
        config.setLogLevel(LogLevel.VERBOSE);
        config.setOnAttributionChangedListener(new OnAttributionChangedListener(){
            @Override
            public void onAttributionChanged(AdjustAttribution attribution) {
                m_status = attribution.trackerToken;
            }
        });
        Adjust.onCreate(config);
        context.registerActivityLifecycleCallbacks(new AdjustLifecycleCallbacks());
    }

    private static final class AdjustLifecycleCallbacks implements Application.ActivityLifecycleCallbacks {
        @Override
        public void onActivityCreated(Activity activity, Bundle bundle) {

        }

        @Override
        public void onActivityStarted(Activity activity) {

        }

        @Override
        public void onActivityResumed(Activity activity) {
            Adjust.onResume();
        }

        @Override
        public void onActivityPaused(Activity activity) {
            Adjust.onPause();
        }

        @Override
        public void onActivityStopped(Activity activity) {

        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {

        }

        @Override
        public void onActivityDestroyed(Activity activity) {

        }

        //...
    }

    public static String getUserAdInfo(){
        String adInfo = "";
        try{
            AdjustAttribution attribution = Adjust.getAttribution();
            String adCampaignId = attribution.campaign;//广告系列编号
            String adGroupId = attribution.adgroup;//广告组编号
            String adCreative = attribution.creative;//广告编号
            m_status = attribution.trackerToken;
            Log.i("Adjust", "adCampaignId:" + adCampaignId);
            Log.i("Adjust", "adGroupId:" + adGroupId);
            Log.i("Adjust", "adCreative:" + adCreative);
            adInfo = adGroupId + ";;;" + adCreative + ";;;" + adCampaignId;
        }catch(Exception e){
            e.printStackTrace();
        }
        return adInfo;
    }

    public static String getAdjustKey(){
        return m_ctx.getResources().getString(R.string.adjust_key);
    }

    public static void adjustLogEvent(String data){
        Log.i("Adjust", "adjustLogEvent eventName:" + data);
//        getUserAdInfo();
        Map<String, Object> m_data = new HashMap<String, Object>();
        JSONObject json = JSONObject.parseObject(data);
        Iterator it = json.entrySet().iterator();
        String eventType = "";
        String revenue = "0";
        while(it.hasNext()){
            Map.Entry entry = (Map.Entry) it.next();
            String key = entry.getKey().toString();
            Object value = entry.getValue();
            if(key.equals("event_type")){
                eventType = value.toString();
            }else if(key.equals("ad_revenue")){
                revenue = value.toString();
            }else
            {
                m_data.put(key, value);
            }
        }
        AdjustEvent adjustEvent = new AdjustEvent(eventType);
        if(Float.parseFloat(revenue) != 0){
            adjustEvent.setRevenue(Float.parseFloat(revenue), "BRL");
        }
        Adjust.trackEvent(adjustEvent);
    }
    public static String getAfStatus(){
        return m_status;
    }
    public static String getAdid(){
        String adid = Adjust.getAdid();
        return adid;
    }
}
