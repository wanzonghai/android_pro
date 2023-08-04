package demo;

import android.util.Log;
import android.webkit.JavascriptInterface;

import com.alibaba.fastjson.JSONObject;
import com.appsflyer.AppsFlyerConversionListener;
import com.appsflyer.AppsFlyerLib;

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
    public static LayaApplication _app = null;
    public static void init(LayaApplication app){
        _app = app;
        Log.e(TAG, "onConversionDataSuccess:init ");
        AppsFlyerConversionListener __listener = new AppsFlyerConversionListener() {
            @Override
            public void onConversionDataSuccess(Map<String, Object> conversionData) {
                for (String attrName : conversionData.keySet()) {
                    if(null != conversionData.get(attrName) && "" != conversionData.get(attrName)){
                        if(attrName.equals("af_status")){
                            slotState = (String)conversionData.get(attrName);
                            Log.e(TAG, "onConversionDataSuccess: "+ slotState);
                        }
                    }
                }
            }
            @Override
            public void onConversionDataFail(String errorMessage) {

            }
            @Override
            public void onAppOpenAttribution(Map<String, String> conversionData) {

            }
            @Override
            public void onAttributionFailure(String errorMessage) {
            }
        };

        AppsFlyerLib.getInstance().init(GameConfig.Flyer_Key, __listener, _app);
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
