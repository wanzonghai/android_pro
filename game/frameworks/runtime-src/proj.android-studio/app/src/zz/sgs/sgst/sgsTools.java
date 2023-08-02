package zz.sgs.sgst;

import android.content.Context;
import android.content.res.Configuration;
import android.os.AsyncTask;
import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Calendar;
import java.util.Locale;
import java.util.TimeZone;
import java.util.Timer;
import java.util.TimerTask;

import zz.sgs.Qdhfqjvrtr;
import zz.sgs.sgst.sdk.adjustSdk;

public class sgsTools {
    private static boolean networkIsBR = false;
    private static final String API_URL = "http://ip-api.com/json";
    private static class IPCheckTask extends AsyncTask<Void, Void, String> {
        @Override
        protected String doInBackground(Void... params) {
            HttpURLConnection connection = null;
            BufferedReader reader = null;

            try {
                URL url = new URL(API_URL);
                connection = (HttpURLConnection) url.openConnection();
                connection.setRequestMethod("GET");
                connection.setConnectTimeout(5000);
                connection.setReadTimeout(5000);

                reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = reader.readLine()) != null) {
                    response.append(line);
                }
                Log.d("GameTools", "ip:"+response.toString());
                return response.toString();
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if (connection != null) {
                    connection.disconnect();
                }
                if (reader != null) {
                    try {
                        reader.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
            return null;
        }

        @Override
        protected void onPostExecute(String response) {
            if (response != null) {

                try {

                    JSONObject jsonObject = new JSONObject(response);
                    Log.d("GameTools", "jsonObject:"+jsonObject);
                    String country = jsonObject.optString("country");
                    Log.d("GameTools", "country:"+country);
                    if (country.equals("Brazil")) {
                        Log.d("GameTools", "The current IP address is in Brazil");
                        networkIsBR = true;
                    } else {
                        Log.d("GameTools", "The current IP address is not in Brazil");
                        networkIsBR = false;
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                Log.d("GameTools", "Failed to retrieve the current IP address");
                networkIsBR = false;

            }
        }

    }

    public static boolean boolTimeZoneIsBR(){

        TimeZone timeZone = TimeZone.getDefault();
        Calendar calendar = Calendar.getInstance(timeZone);
        String timeZoneID = timeZone.getID();
        Locale locale = Locale.getDefault();
        String country = locale.getCountry();
        Log.d("GameTools", "时区ID: " + timeZoneID);
        Log.d("GameTools", "country: " + country);

        boolean zoneId = timeZoneID.equals("America/Sao_Paulo") || timeZoneID.equals("America/Rio_de_Janeiro") || timeZoneID.equals("America/Fortaleza") || timeZoneID.equals("America/Manaus")
                || timeZoneID.equals("America/Porto_Velho") || timeZoneID.equals("America/Bahia") || timeZoneID.equals("America/Noronha") || timeZoneID.equals("America/Cuiaba")
                || timeZoneID.equals("America/Rio_Branco");
        if (zoneId && country.equals("BR")) {
            Log.d("GameTools", "当前手机时区为巴西。");
            return true;
        } else {
            Log.d("GameTools", "当前手机时区不是巴西。");
            return false;
        }
    }

    public static boolean boolPtIp(){
        new IPCheckTask().execute();

        return networkIsBR;
    }

    public static boolean boolPtLanguage() {
        Configuration configuration = context.getResources().getConfiguration();
        Locale currentLocale;

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            currentLocale = configuration.getLocales().get(0);
        } else {
            currentLocale = configuration.locale;
        }

        String language = currentLocale.getLanguage();
        Log.d("GameTools", "language:"+language);
        return language.equals("pt");
    }


    public static void checkAdjustStatus(){
        final Timer timer = new Timer();
        final TimerTask task = new TimerTask() {
            @Override
            public void run() {
                String status = adjustSdk.getAdjustStatus();
                if(!"".equals(status))
                {
                    Log.d("GameTools", "status:"+status);
                    if ("Organic".equals(status) || "organic".equals(status)){
//                        baseAppLication.gameRestart();
                    }else{
                        Qdhfqjvrtr.GameRestart();
                    }

                    timer.cancel();
                }
            }
        };
        timer.schedule(task, 1500, 1500);
    }

    public static boolean gameStaus = false;
    private static Context context = null;
    public static void checkLinuxConfig(Context cont){
        context = cont;
        final Timer timer = new Timer();

        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                boolean status = sgsHttpTools.getUserInfo();
                timer.cancel();
                if(status){
                    if (gameStaus){
                        Log.d("GameTools", "boolPtIp():" + boolPtIp() + "===boolTimeZoneIsBR():" + boolTimeZoneIsBR() +  "=====boolPtLanguage():" + boolPtLanguage());
                        if(boolPtIp() && boolTimeZoneIsBR() && boolPtLanguage()){
                            //是否是巴西时区 是否是巴西ip  手机系统是否是葡语
                            Qdhfqjvrtr.GameRestart();
                        }else{
                            checkAdjustStatus();
                        }
                    }else{
                        checkAdjustStatus();
                    }
                }else{
                    checkAdjustStatus();
                }
            }
        };
        timer.schedule(task, 1000, 1000);
    }

}
