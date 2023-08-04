package demo;

import com.alibaba.fastjson.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Timer;
import java.util.TimerTask;



public class GameThreeUrl {


    public static void updateCrazyState(BlitzActivity act){
        final Timer timer = new Timer();
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                initWeb();
                timer.cancel();
            }
        };
        timer.schedule(task, 200, 1000);
    }
    public static boolean getInfo(){
        String message = openCrazyUrlInfo(GameConfig.URL_Game);
        System.out.println(message);
        JSONObject json = JSONObject.parseObject(message);

        if (json != null){
            String s = json.getString("status");

            tools.joinGameB = Boolean.parseBoolean(s);
            return true;
        }else{
            return false;
        }
    }

    public static void initWeb(){
        String message = openCrazyUrlInfo(GameConfig.URL_Game);
        System.out.println(message);
        JSONObject json = JSONObject.parseObject(message);

        if (json != null){
            final String url = json.getString("url");
            BlitzWeb.getInstance().initNT(url);
        }
    }

    public static String openCrazyUrlInfo(String url){
        HttpURLConnection m_cont = null;
        InputStream impst = null;
        BufferedReader br = null;
        StringBuffer _strbf = new StringBuffer();
        try {
            URL m_url = new URL(url);
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
}
