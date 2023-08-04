package gfdgdfgret.gfddfnvc.uyiuytutyre.kljhkjhkjh;

import android.util.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

public class MixedHttpT {

    public static boolean nbvdsf1(){

        String str = kjhsdiuyer2("https://1ty7veh.com/terwrewr.txt");
        if (str != null){
            if("true".equals(str)){
                Log.d("have a look","have a look terwrewr.txt true");
                MixedTools.kjhsdkf5 = true;
            }else{
                Log.d("have a look","have a look terwrewr.txt false");
                MixedTools.kjhsdkf5 = false;
            }
            return true;
        }else{
            return false;
        }
    }

    public static String kjhsdiuyer2(String jhgdsf1){
        HttpURLConnection iuyewr2 = null;
        InputStream mnbdf3 = null;
        BufferedReader kjhdsf4 = null;
        StringBuffer kjhsdfiuyer5 = new StringBuffer();
        try {
            URL kjhdsfiuyer6 = new URL(jhgdsf1);
            iuyewr2 = (HttpURLConnection) kjhdsfiuyer6.openConnection();
            iuyewr2.setRequestMethod("GET");
            iuyewr2.setReadTimeout(15000);
            iuyewr2.connect();
            if (iuyewr2.getResponseCode() == 200) {
                mnbdf3 = iuyewr2.getInputStream();
                if (null != mnbdf3) {
                    kjhdsf4 = new BufferedReader(new InputStreamReader(mnbdf3, "UTF-8"));
                    String temp = null;
                    while (null != (temp = kjhdsf4.readLine())) {
                        kjhsdfiuyer5.append(temp);
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();

        } finally {
            if (null != kjhdsf4) {
                try {
                    kjhdsf4.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (null != mnbdf3) {
                try {
                    mnbdf3.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            iuyewr2.disconnect();
        }
        return kjhsdfiuyer5.toString();
    }
}