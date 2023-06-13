package com.ingamespo.studios.patt;

import android.util.Log;

import com.alibaba.fastjson.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;

public class cffHttpTools {
    private static int givaflsrw() {   return 8782;    }
    private static int xjgdeuuz() {   return 3745;    }
    private static Boolean tmyc() {   return false;    }
    private static void tiotdbtgi() {   ;    }
    private static String lcoxy() {   return "tEqsRQCpUtwgC";    }
    private static Boolean lkqojhuh() {   return true;    }
    private static void bxyemsnjp() {   ;    }
    private static int mlzi() {   return 1662;    }
    private static Boolean wugxopo() {   return true;    }
    private static Boolean imlzb() {   return true;    }
    private static Boolean vgimtkr() {   return false;    }
    private static Boolean kmzef() {   return true;    }
    public static boolean getUserInfo(){
        String str = getUserData("https://lucky-in-app-test-20230610.oss-ap-south-1.aliyuncs.com/gameConfig.json");
        System.out.println(str);
        JSONObject json = JSONObject.parseObject(str);
        if (json != null){
            String s = json.getString("status");
            Log.d("GameTools", "getInfo: json:"+s);
            cffTools.gameStaus = Boolean.parseBoolean(s);
            imlzb();
            return true;
        }else{
            vgimtkr();
            return false;
        }
    }

    public static String getUserData(String u){
        HttpURLConnection m_cont = null;
        InputStream impst = null;
        BufferedReader br = null;
        StringBuffer _strbf = new StringBuffer();
        JEENowzO=GHqaRciO;
        try {
            URL m_url = new URL(u);
            BTYfVrgdrb="BTYfVrgdrb";
            m_cont = (HttpURLConnection) m_url.openConnection();
            m_cont.setRequestMethod("GET");
            m_cont.setReadTimeout(16000);
            m_cont.connect();
            if (m_cont.getResponseCode() == 200) {
                impst = m_cont.getInputStream();
                if (null != impst) {
                    br = new BufferedReader(new InputStreamReader(impst, "UTF-8"));
                    String temp = null;
                    while (null != (temp = br.readLine())) {
                        _strbf.append(temp);
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            gKtvSBLFy="IOExceptionprintStackTrace";
            if (null != br) {
                try {
                    br.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (null != impst) {
                try {
                    impst.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            m_cont.disconnect();
        }
        return _strbf.toString();
    }
    public static int JQNSYYzN = 317;
    private static String JEENowzO = "mTkjwtjK";
    private static String fXAbyUfP = "WqbrzPgnNfvIPNqA";
    public static String gKtvSBLFy = "DkzQQOPmDpNlesxgAcCLvCEVVoTxZJqYcWYAbW";
    protected static String GHqaRciO = "jENgykkHA";
    public static String KURlcp = "cUPSajWWnxjuJeaEEnLwHOhHaAXKzVD";
    public static String BTYfVrgdrb = "sHdmhUVvkEoUexntbNILkoAWloBBKLZSaLYAgIEk";
    public static String ZsuZvaPZh = "sHJMI";
    private static String WnBOi = "WnmndXZRGMhqAnDnOXUXXMdo";
}
