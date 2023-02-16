package truco.three.afsdk;

import android.app.Application;
import android.support.annotation.NonNull;
import android.util.Log;

import com.alibaba.fastjson.JSONObject;
import com.appsflyer.AppsFlyerConversionListener;
import com.appsflyer.AppsFlyerLib;
import com.appsflyer.attribution.AppsFlyerRequestListener;
import com.game.brazil.R;
import truco.three.threeface.Afface;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class AfSdk implements Afface {
    private static Application m_ctx = null;
    private static String m_adseriesId = "";//广告系列编号
    private static String m_adsId = "";//广告组编号 
    private static String m_adId = "";//广告编号
    private static String m_status = "";
    @Override
    public void afInit(Application context) {
        m_ctx = context;
        AppsFlyerConversionListener __conversionListener = new AppsFlyerConversionListener() {
            @Override
            public void onConversionDataSuccess(Map<String, Object> conversionData) {

                for (String attrName : conversionData.keySet()) {
                    Log.d("AfSdk", "attribute: " + attrName + " = " + conversionData.get(attrName));
                    if(null != conversionData.get(attrName) && "" != conversionData.get(attrName)){
                        if(attrName.equals("af_c_id") || attrName.equals("fb_campaign_id") || attrName.equals("adset_id") || attrName.equals("campaign_id"))
                        {
                            m_adseriesId = (String)conversionData.get(attrName);
                        }
                        if(attrName.equals("af_adset_id") || attrName.equals("fb_adset_id") || attrName.equals("ad_id"))
                        {
                            m_adsId = (String)conversionData.get(attrName);
                        }
                        if(attrName.equals("af_ad_id") || attrName.equals("fb_adgroup_id") || attrName.equals("adgroup_id"))
                        {
                            m_adId = (String)conversionData.get(attrName);
                        }
                        if(attrName.equals("af_status")){
                            m_status = (String)conversionData.get(attrName);
                        }
                    }
                }
            }

            @Override
            public void onConversionDataFail(String errorMessage) {
                Log.d("AfSdk", "error getting conversion data: " + errorMessage);
            }

            @Override
            public void onAppOpenAttribution(Map<String, String> conversionData) {

                for (String attrName : conversionData.keySet()) {
                    Log.d("AfSdk", "attribute: " + attrName + " = " + conversionData.get(attrName));
                }

            }

            @Override
            public void onAttributionFailure(String errorMessage) {
                Log.d("AfSdk", "error onAttributionFailure : " + errorMessage);
            }
        };

        AppsFlyerLib.getInstance().init(m_ctx.getResources().getString(R.string.af_key), __conversionListener, context);
        AppsFlyerLib.getInstance().start(context);
    }

    public static String getAFID(){
        return AppsFlyerLib.getInstance().getAppsFlyerUID(m_ctx);
    }

    public static String getAFDEVToken(){
        if(null != m_ctx){
            return m_ctx.getResources().getString(R.string.af_key);
        }
        return "";
    }

    public static String getUserAdInfo(){
        return m_adsId + ";;;" + m_adId + ";;;" + m_adseriesId;
    }

    public static String getAfStatus(){
        return m_status;
    }

    public static void appsFlyerEvent(String data) {
        Log.d("Tools appsFlyerEvent","=====data:"+data);
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
            Log.d("LOG_TAG", "appsflyer事件: " + eventType);
            Log.d("LOG_TAG", String.valueOf(m_data));
            AppsFlyerLib.getInstance().logEvent(m_ctx, eventType, m_data,new AppsFlyerRequestListener() {
                @Override
                public void onSuccess() {
                    Log.d("LOG_TAG", "Event sent successfully");
                }
                @Override
                public void onError(int i, @NonNull String s) {
                    Log.d("LOG_TAG", "Event failed to be sent:\n" +
                            "Error code: " + i + "\n"
                            + "Error description: " + s);
                }
            });
        }
    }
}
