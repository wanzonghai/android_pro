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
import com.adjust.sdk.OnDeviceIdsRead;
import com.alibaba.fastjson.JSONException;
import com.alibaba.fastjson.JSONObject;

import org.master.chileno.R;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import truco.three.threeface.Adjustface;


public class AdjustSdk implements Adjustface {
    private static Context m_ctx = null;
    private static String m_status = "";
    private static String google_adid = "";

    @Override
    public void adjustInit(Application context) {
        Log.d("Adjust", "adjustInit 1");
        m_ctx = context;
        String _apptoken = "zbnkvcxz3g8w";
        Log.d("Adjust", "adjustInit 2" + _apptoken);
        //AdjustConfig.ENVIRONMENT_PRODUCTION 生产环境 AdjustConfig.ENVIRONMENT_SANDBOX 测试开发环境
        String environment = AdjustConfig.ENVIRONMENT_PRODUCTION;
        AdjustConfig config = new AdjustConfig(context, _apptoken, environment);
        config.setLogLevel(LogLevel.VERBOSE);
        Log.d("Adjust", "adjustInit 3");
        config.setOnAttributionChangedListener(new OnAttributionChangedListener(){
            @Override
            public void onAttributionChanged(AdjustAttribution attribution) {
                m_status = attribution.trackerName;
                Log.d("Adjust", "m_status:"+m_status);
            }
        });
        Log.d("Adjust", "adjustInit 4");
        Adjust.onCreate(config);
        Log.d("Adjust", "adjustInit 5");
        context.registerActivityLifecycleCallbacks(new AdjustLifecycleCallbacks());
    }

    private static final class AdjustLifecycleCallbacks implements Application.ActivityLifecycleCallbacks {
        @Override
        public void onActivityCreated(Activity activity, Bundle bundle) {
            Log.d("Adjust", "adjustInit 6");
            setGoogleAdid();
            setAdstatus();
        }

        @Override
        public void onActivityStarted(Activity activity) {
            Log.d("Adjust", "adjustInit 7");
        }

        @Override
        public void onActivityResumed(Activity activity) {
            Log.d("Adjust", "adjustInit 8");
            Adjust.onResume();
        }

        @Override
        public void onActivityPaused(Activity activity) {
            Log.d("Adjust", "adjustInit 9");
            Adjust.onPause();
        }

        @Override
        public void onActivityStopped(Activity activity) {
            Log.d("Adjust", "adjustInit 10");
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
            Log.d("Adjust", "adjustInit 11");
        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            Log.d("Adjust", "adjustInit 12");
        }

        //...
    }

    public static void setAdstatus(){
        try{
            AdjustAttribution attribution = Adjust.getAttribution();
            Log.d("Adjust", "========getAdstatus: "+attribution.trackerName);
            m_status = attribution.trackerName;
        }catch(Exception e){
            e.printStackTrace();
        }
    }

    public static void setGoogleAdid(){
        Adjust.getGoogleAdId(m_ctx, new OnDeviceIdsRead() {
            @Override
            public void onGoogleAdIdRead(String googleAdId) {
                google_adid = googleAdId;
                Log.d("Adjust", "onGoogleAdIdRead:google_adid:"+google_adid);
            }
        });
    }

    public static String getAdjustId(){
        String adid = Adjust.getAdid();
        return adid;
    }

    public static String getAdjustAttribution(){
        JSONObject result = new JSONObject();
        AdjustAttribution aa = Adjust.getAttribution();
        try {
            if (null!=aa){
                if (aa.trackerToken!=null){
                    result.put("trackerToken", aa.trackerToken);
                }
                if (aa.trackerName!=null){
                    result.put("trackerName", aa.trackerName);
                }
                if (aa.network!=null){
                    result.put("network", aa.network);
                }
                if (aa.campaign!=null){
                    result.put("campaign", aa.campaign);
                }
                if (aa.adgroup!=null){
                    result.put("adgroup", aa.adgroup);
                }
                if (aa.creative!=null){
                    result.put("creative", aa.creative);
                }
                if (aa.clickLabel!=null){
                    result.put("clickLabel", aa.clickLabel);
                }
                if (aa.adid!=null){
                    result.put("adid", aa.adid);
                }
            }
        }catch(JSONException e){
            e.printStackTrace();
        }
        String resultString = result.toString();

        return resultString;
    }


    public static String getGoogleAdid(){
        Log.d("Adjust", "getGoogleAdid: "+google_adid);
        return google_adid;
    }

    public static String getAdjustKey(){
        return "zbnkvcxz3g8w";
    }

    public static String getAdjustStatus(){
        Log.d("Adjust", "========m_status: "+m_status);
        return m_status;
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
