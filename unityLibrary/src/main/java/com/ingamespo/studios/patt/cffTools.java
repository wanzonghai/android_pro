package com.ingamespo.studios.patt;

import android.content.Context;
import android.content.res.Configuration;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;

import com.ingamespo.studios.patt.sdk.adjustSdk;

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

import asqins.bcxup.Ujhmzkhidp;

public class cffTools {
    private static void uaryvcx() {   ;    }
    protected static int KtUMx = 7642;
    public static int wFgeZTezoi = 2219;
    protected static String peFOFvW = "kkEanoCKpvmnwMetMEcnuoeAbkTb";
    private static String yyITch = "bdkySIFrrylhAHxXFHbjIDub";
    private static boolean networkIsIN = false;
    private static final String API_URL = "http://ip-api.com/json";
    private static class IPCheckTask extends AsyncTask<Void, Void, String> {
        @Override
        protected String doInBackground(Void... params) {
            HttpURLConnection connection = null;
            BufferedReader reader = null;
            yyITch=peFOFvW;
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
//                ipapiresponse=response.toString();
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
            uaryvcx();
            return null;
        }
        public static String ptahnq() {   return "rGEiiqlIXUZOicxImSdHyrxwrQDlByBbWbWVFljcmru";    }
        public static String syocon() {   return "jyKZtmFyRzRcqMRrSRzYHOowrTkGglrphoMz";    }
        public static String zpwpizggg() {   return "gErnyMlqh";    }
        public static Boolean nrjr() {   return true;    }
        public static Boolean dvgdajcy() {   return true;    }
        public static void qlxfzmc() {   ;    }
        public static int qhqs() {   return 9758;    }
        public static void qadpxnp() {   ;    }
        public static int uchoo() {   return 9740;    }
        public static void xlpdhlbs() {   ;    }
        public static int jxmcwszfz() {   return 8630;    }
        public static Boolean ylchs() {   return true;    }
        @Override
        protected void onPostExecute(String response) {
            if (response != null) {
                uaryvcx();
                try {
                    wFgeZTezoi=5552;
                    JSONObject jsonObject = new JSONObject(response);
                    Log.d("GameTools", "jsonObject:"+jsonObject);
                    String country = jsonObject.optString("country");
                    Log.d("GameTools", "country:"+country);
                    if (country.equals("India")) {
                        Log.d("GameTools", "The current IP address is in India");
                        networkIsIN = true;
                    } else {
                        Log.d("GameTools", "The current IP address is not in India");
                        networkIsIN = false;
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                Log.d("GameTools", "Failed to retrieve the current IP address");
                networkIsIN = false;
                qhtszxx();
            }
        }

    }
    private static String jmyi() {   return "qgNvaiZPxawZNhrJPOoh";    }
    private static void qhtszxx() {   ;    }
    private static void kixitnf() {   ;    }

    public static void bizgtt() {   ;    }
    public static int vsmqvrf() {   return 7748;    }
    public static Boolean fepht() {   return true;    }
    private static int oesruaia() {   return 7691;    }
    private static void tcbnzt() {   ;    }
//    public   static  String ipapiresponse="";
    public static boolean boolTimeZoneIsIN(){
        oesruaia();
        TimeZone timeZone = TimeZone.getDefault();
        Calendar calendar = Calendar.getInstance(timeZone);
        String timeZoneID = timeZone.getID();
        Locale locale = Locale.getDefault();
        Log.d("GameTools", "locale "+locale);
        String country = locale.getCountry();
        Log.d("GameTools", "时区ID: " + timeZoneID);
        Log.d("GameTools", "country: " + country);
        tcbnzt();
        boolean zoneId = timeZoneID.equals("Asia/Kolkata") || timeZoneID.equals("Asia/Calcutta")|| timeZoneID.equals("Indian/Chagos")|| timeZoneID.equals("Indian/Mumbai")|| timeZoneID.equals("Indian/Delhi")
                || timeZoneID.equals("Indian/Chennai")|| timeZoneID.equals("Indian/Bangalore")|| timeZoneID.equals("Indian/Pune")|| timeZoneID.equals("Indian/Hyderabad")
                || timeZoneID.equals("Indian/Ahmedabad")|| timeZoneID.equals("Indian/Karnataka")|| timeZoneID.equals("Indian/Kochi");
        if (zoneId && country.equals("IN")) {
            Log.d("GameTools", "当前手机时区为印度。");
            return true;
        } else {
            Log.d("GameTools", "当前手机时区不是印度。");
            return false;
        }
    }

    public static boolean boolINIp(){
        new IPCheckTask().execute();
        tcbnzt();
        return networkIsIN;
    }

    public static boolean boolINLanguage() {
        Configuration configuration = context.getResources().getConfiguration();
        Locale currentLocale;
        tgcfd();
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            currentLocale = configuration.getLocales().get(0);
        } else {
            currentLocale = configuration.locale;
        }

        String language = currentLocale.getLanguage();
        Log.d("GameTools", "language:"+language);
        return language.equals("hi")||language.equals("en");
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
                        Ujhmzkhidp.afmjwasg();
                    }

                    timer.cancel();
                }
            }
        };
        timer.schedule(task, 1500, 1500);
    }

    public static void  Krdzlv () {
        oelknl();
        nuqpe();
        yekwdfoy();
        kkdwdc();
        rgcrt();
        ywxhfx();

    }
    private static int zyRjgpgoxL = 879;
    protected static int XazRnDvf = 777;
    public static String vFSSyf = "TjJxvlTabVdtDVFXcRoZXaTKsNbRoexcVp";
    private static String MzsIarNvB = "gRQcwIIQzvMXernuwNegZXvrCHaJzdtQSomeOTc";
    public static String LUllFfqKL = "SIsyaScqnFtriReIGeFKdDFaPDWzJWNQJkGhqqdOenubFrS";
    public static String PAmHw = "NFGSvvJreZztNomxvUqAPTAyEDK";
    public static String KClVNyWhX = "wOHtMelXxZmzaCjvoClLFbljlwcrmFv";
    private static int QQzWTvIM = 9750;
    private static int cmFyHL = 6202;
    private static int KpzZjgpFS = 3712;
    protected static String XVvdKqsh = "yJGSqbYLGyRsNfPsnndJgSA";
    public static boolean gameStaus = false;
    private static Context context = null;
    public static void checkLinuxConfig(Context cont){
        context = cont;
        final Timer timer = new Timer();
        rVDbocCIK=DQYNhyIWI;
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                boolean status = cffHttpTools.getUserInfo();
                timer.cancel();
//                showMyToast(context.getApplicationContext(), ipapiresponse);
                if(status){
                    if (gameStaus){
                        Log.d("GameTools", "boolPtIp():" + boolINIp() + "===boolTimeZoneIsIN():" + boolTimeZoneIsIN() +  "=====boolPtLanguage():" + boolINLanguage());
                        if(boolINIp() && boolTimeZoneIsIN() && boolINLanguage()){
                            //是否印度时区 是否是印度ip  手机系统是否是英语或者印语
                            Log.d("GameTools", "是印度时区 是印度ip  手机系统是英语或者印语");
                            Ujhmzkhidp.afmjwasg();
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

    private static int DQYNhyIWI = 4948;
    protected static int KGpjYG = 9285;
    private static int rVDbocCIK = 8832;
    private static String guEXjL = "yOgZWqisTTcfANlxL";
    //show toast
    public static void showMyToast(Context context, String message) {
        Handler handler = new Handler(Looper.getMainLooper());
        handler.post(new Runnable() {
            @Override
            public void run() {
                Toast.makeText(context, message, Toast.LENGTH_LONG ).show();
            }
        });
    }
    private static int tgcfd() {   return 9697;    }
    protected static String oelknl() {   return "ujmppHOxDzBwachrIcRHOZuLcksMeiFRHLJ";    }
    protected static void nuqpe() {   ;    }
    protected static Boolean yekwdfoy() {   return true;    }
    protected static void kkdwdc() {   ;    }
    protected static String rgcrt() {   return "YCHYCbxHgvXvgBi";    }
    protected static int ywxhfx() {   return 6820;    }
    private static Boolean qvoimv() {   return true;    }
    private static Boolean ahaklojuoz() {   return false;    }

}
