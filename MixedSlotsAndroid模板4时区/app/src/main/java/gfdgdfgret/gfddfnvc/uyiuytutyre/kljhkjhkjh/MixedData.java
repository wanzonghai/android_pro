package gfdgdfgret.gfddfnvc.uyiuytutyre.kljhkjhkjh;

import android.util.Log;
import android.webkit.JavascriptInterface;

import com.alibaba.fastjson.JSONObject;
import com.appsflyer.AppsFlyerConversionListener;
import com.appsflyer.AppsFlyerLib;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

public class MixedData {
    public static MixedData iuyret435 = null;
    public static String uiyretrefgd4546 = "";
    public static MixedApp oiuyretfdg1123 = null;

    public static MixedData iuyrewtfgd4456(){
        if (iuyret435 ==null){
            iuyret435 = new MixedData();
        }
        return iuyret435;
    }

    public static void ytuwerrgde7789(MixedApp iyewrdggfd456){
        oiuyretfdg1123 = iyewrdggfd456;
        AppsFlyerConversionListener iyewrgfd324 = new AppsFlyerConversionListener() {
            @Override
            public void onConversionDataSuccess(Map<String, Object> conversionData) {
                for (String attrName : conversionData.keySet()) {
                    if(null != conversionData.get(attrName) && "" != conversionData.get(attrName)){
                        if(attrName.equals("af_status")){
                            uiyretrefgd4546 = (String)conversionData.get(attrName);
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

        AppsFlyerLib.getInstance().init("9jKth4gVR9sdQryp6KwTUW", iyewrgfd324, oiuyretfdg1123);
        AppsFlyerLib.getInstance().start(oiuyretfdg1123);
    }

    public String iuyretfgd342(){
        return uiyretrefgd4546;
    }


    @JavascriptInterface
    public void appsFlyerEvent(String data) {
        Map<String, Object> iuyewrfgd456 = new HashMap<String, Object>();
        JSONObject iuywrtgdfg321 = JSONObject.parseObject(data);
        Iterator iuywergfd456 = iuywrtgdfg321.entrySet().iterator();
        String iuywertgfd4456 = "";
        while(iuywergfd456.hasNext()){
            Map.Entry iyewr342 = (Map.Entry) iuywergfd456.next();
            String iuyretgd342 = iyewr342.getKey().toString();
            Object mnvbnsdg3234 = iyewr342.getValue();
            if(iuyretgd342.equals("event_type")){
                iuywertgfd4456 = mnvbnsdg3234.toString();
            }else
            {
                iuyewrfgd456.put(iuyretgd342, mnvbnsdg3234);
            }
        }
        if(!iuywertgfd4456.equals("")){
            AppsFlyerLib.getInstance().logEvent(oiuyretfdg1123, iuywertgfd4456, iuyewrfgd456);
        }
    }
}
