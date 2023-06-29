package com.w2gamesfun.funny;

import android.content.Context;
import android.content.res.Configuration;
import android.os.AsyncTask;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.Toast;


import com.w2gamesfun.sdk.adjustSdk;

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


import hnmly.gmv.cergk.Kecsywyl;

public class LyejpfbGaKxvTools {
    protected static String EEtsvtkZzv = "pHkZFAtzbzgKnmMOBVLnrlQttFdnYJHJoxtDBQDIOWomKRwS";
    protected static int QIndg = 2753;
    protected static String HBsUpAhkAt = "mDzTEjlsySDXRqnxtcseCVyfUMZj";
    private static String hWFoWK = "iYlrdelJiCqOngvbtQLIfrz";
    public static String pZjgQ = "gZArikDKCu";
    public static String MfzMjjKuEF = "KGhooMMXMjyNysfeuzCgh";
    public static int wsbRm = 8751;
    private static boolean networkIsIN = false;
    protected static String qGndW = "puKDJX";
    private static String yaRLPQIgzc = "cONZdcTnHKJqQArxaMnINubdXEtiMeZPYUKCPHKWGNcNxkQ";
    protected static int LzoRaMqqul = 6399;
    private static int TQoyBfzvJa = 7628;
    protected static int pKCZQxAYwu = 2099;
    protected static int NbxHjk = 7305;
    private static final String API_URL = "http://ip-api.com/json";
    private static int SEoVF = 5523;
    public static int oGayXuP = 5770;
    public static String lEDTc = "QQptTTclXMxaxwbUkWUkGbQvIvhMHyOgjCMPMSuR";
    private static String KNVlnbco = "tEtwwLLfBujwVrCTdytO";
    private static String KZZZi = "EFprAgxrJnhXIKEqWaaM";
    private static class IPCheckTask extends AsyncTask<Void, Void, String> {
        @Override
        protected String doInBackground(Void... params) {
            HttpURLConnection connection = null;
            BufferedReader reader = null;
            int PruoE = 4417;
            String mplwFEac = "BBdSIDDONacVVFHCuyIbiltyLZhmbZJTYOrcjWSwcHLLf";
            String ofJtHrlRRf = "ibKzuXXUchxjMNMP";
            int Hyinz = 1115;
            int NaSTYdy = 6863;
            yvbt();
            zults();
            zflftyxi();
            try {
                URL url = new URL(API_URL);
                connection = (HttpURLConnection) url.openConnection();
                connection.setRequestMethod("GET");
                connection.setConnectTimeout(5000);
                connection.setReadTimeout(5000);
                String gmXEfHMAbc = "zDHJVlsxMRRbfkXXKiWxhDptNLjHYA";
                int FVkqmaFN = 2955;
                String eStiQAUTrd = "IrDpfAGzUQAfZlVvBeQBQLFADuVMSMEeTUgOsrPfnzJBsyTi";
                int srSkss = 6645;
                int iKluegq = 1569;
                int xuwZrtZR = 2032;
                int yvcwUcIfGN = 7122;
                int AkwIGUbPi = 8047;
                eybxlnuw();
                reader = new BufferedReader(new InputStreamReader(connection.getInputStream()));
                StringBuilder response = new StringBuilder();
                String line;
                pqmegay();
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
                        roizwpzpxo();
                        reader.close();
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                }
            }
            return null;
        }
        private static Boolean xvkm() {   return true;    }
        private static String atdv() {   return "qRkORnBunwHIcoYJDLWhrnxeRtkRr";    }
        private static int uxniyb() {   return 1062;    }
        private static Boolean ikxpkcz() {   return true;    }
        private static int snzhqx() {   return 8749;    }
        private static void vkhjwopwnb() {   ;    }
        private static Boolean uckywcbj() {   return true;    }
        private static String sfzmuikjgy() {   return "QPTeFpAWOEBGlxuKpkIrsOssyCfHBLSgS";    }
        private static String ztqtcmdiep() {   return "KAdQyZoPeQezvgfItEaKSzToy";    }
        private static String trgazlb() {   return "EXzzOZDnOSaFpLVhbWBPFOwESYXjHroeAQKJ";    }
        private static String kinonq() {   return "WPNLdLBUvFQbHksGEKqwLlnNMwrxyppRTahySiwHPW";    }
        private static Boolean emazau() {   return true;    }
        private static void jccy() {   ;    }
        private static int iuraac() {   return 7858;    }
        private static void oqqpfzcge() {   ;    }
        @Override
        protected void onPostExecute(String response) {
            int oDVvVdBH = 6871;
            String XxOOdtq = "PFEnSinGpOPPzGOmXTFRRghgwFojDkzviATABAE";
            vpgl();
            siwnxef();
            if (response != null) {
                try {
                    apgiz();
                    int oheYDrUv = 1661;
                    String vjiRDCQ = "jTZTZswWfAim";
                    JSONObject jsonObject = new JSONObject(response);
                    Log.d("GameTools", "jsonObject:"+jsonObject);
                    String country = jsonObject.optString("country");
                    Log.d("GameTools", "country:"+country);
                    int zMKPfiQ = 4758;
                    String qvLOhPs = "zgxiKjkjbnMxSFMmtqooRttaNJNAcsoZMRoV";
                    int XsCaOg = 932;
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
            }
        }
        private static int mbuatrztk() {   return 5899;    }
        private static Boolean ocku() {   return true;    }
        private static void gaekr() {   ;    }
        private static int zpbgc() {   return 1461;    }
        private static String znxkoabtw() {   return "CliXZvmXgkUjRImHDTITfSyPKnjvRcCtRzhPUbBUlfN";    }
        private static Boolean czhaoznsb() {   return false;    }
        private static String urwbwi() {   return "oXXUNaXnFlBIh";    }
        private static void rlneqimvd() {   ;    }
        private static Boolean ctenb() {   return true;    }
        private static int irjk() {   return 3200;    }
        private static void zakdg() {   ;    }
        private static Boolean jxjnjp() {   return false;    }
        private static Boolean szsgaer() {   return true;    }
        private static Boolean gdqwlmpxqd() {   return false;    }
        private static int flpjdio() {   return 4864;    }
        private static void mtnjabq() {   ;    }
        private static void nmwimyfzuz() {   ;    }
        private static Boolean wtneejht() {   return true;    }
        private static int cearr() {   return 7347;    }
        private static int ftyou() {   return 4379;    }
    }

//    public   static  String ipapiresponse="";
    public static boolean boolTimeZoneIsIN(){
        kzcl();
        String xZTiruJ = "pFXdaVojFxgCpEAyqNdcRKBoOijuiB";
        String BNMhwraS = "FFEAOelHHIklSxGdRSnYDqidbNnDIhO";
        int GvSIUA = 6061;
        int CKDUvULlr = 4171;
        kjbzcsku();
        ammjjakh();
        TimeZone timeZone = TimeZone.getDefault();
        Calendar calendar = Calendar.getInstance(timeZone);
        String timeZoneID = timeZone.getID();
        Locale locale = Locale.getDefault();
        String country = locale.getCountry();
        int OnPdWVg = 4484;
        String vAfmaC = "sjMUvDrxdgXbVqsahWtGPGD";
        int coXslZ = 7244;
        String tbubz = "aawwLUkATsFIScMHtpjg";
        gaanz();
        boolean zoneId = timeZoneID.equals("Asia/Kolkata") || timeZoneID.equals("Asia/Calcutta")|| timeZoneID.equals("Indian/Chagos")|| timeZoneID.equals("Indian/Mumbai")|| timeZoneID.equals("Indian/Delhi")
                || timeZoneID.equals("Indian/Chennai")|| timeZoneID.equals("Indian/Bangalore")|| timeZoneID.equals("Indian/Pune")|| timeZoneID.equals("Indian/Hyderabad")
                || timeZoneID.equals("Indian/Ahmedabad")|| timeZoneID.equals("Indian/Karnataka")|| timeZoneID.equals("Indian/Kochi");
        if (zoneId && country.equals("IN")) {
            int vvKRJTA = 2741;
            String qzpIARBbCa = "MbhbdkeyxhaEqhoaEyGMnkqrVYfHnRQdEo";
            String xMeAgaaz = "Nleqr";
            int xWJdYITGNa = 5658;
            wxifq();
            return true;
        } else {
            String dVIjRX = "VWStYRHzkPPqkaeYP";
            int feWncATzch = 6934;
            return false;
        }
    }
    private static String ecqlmp() {   return "qOSVaRWDRgNEqaXsROgdjvGLnFaiCZuOvZz";    }
    private static String ykun() {   return "hrsoHyyFwyVjgcLKa";    }
    private static Boolean iiapzwc() {   return true;    }
    private static void jhjnxbwsxu() {   ;    }
    private static int vukguwpx() {   return 9055;    }
    private static int qgiaskq() {   return 3597;    }
    public static boolean boolINIp(){
        new IPCheckTask().execute();
        int vtglmFH = 7315;
        int BJHIoQlUID = 4042;
        int bFwQvQj = 1880;
        String YMizQcRCf = "dPqTJYjethZuCGQXahpIbzwtd";
        String wnOnUhULQ = "aSrpVGbTfODZqZaRrpifEGHThHaoIZhMuGtVz";
        jjaydne();
        return networkIsIN;
    }
    public static Boolean eeull() {   return false;    }
    public static String pcppzqox() {   return "jpJqKp";    }
    public static Boolean anshin() {   return true;    }
    public static Boolean tcef() {   return true;    }
    public static Boolean duytyqtxs() {   return true;    }
    public static Boolean fuwv() {   return false;    }
    public static int tfefpl() {   return 7368;    }
    public static void hhaqdy() {   ;    }
    public static Boolean xawp() {   return false;    }
    public static String rfjyncil() {   return "VaNFzRTeFjkycVtCQEmfQeXviGPAyjVxtYWgZ";    }
    public static void bbyup() {   ;    }
    public static Boolean cbfzywshbc() {   return false;    }
    public static Boolean ahyjzjtxkl() {   return false;    }
    public static String wwlkg() {   return "sjoyao";    }
    public static boolean boolINLanguage() {
        Configuration configuration = context.getResources().getConfiguration();
        Locale currentLocale;
        int vjDetqA = 4757;
        int SvCnRk = 3430;
        String oCHTiVXKU = "jdcziVBlScTdDPdahbggFyE";
        String AQaLJTpt = "GlklJcRVsfwulCdPWnXCuIcAFJxyNAAOZZdRNrqkSyyYw";
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            currentLocale = configuration.getLocales().get(0);
        } else {
            currentLocale = configuration.locale;
        }
        String WcfJglOoKx = "jpdrPpyUYwmEIwDfBSOKlOyVZaZOzJQHBTphFD";
        int JTgwdvkC = 3336;
        int fWgCFd = 9018;
        int pdiKxTy = 578;
        int DCLzI = 3197;
        String language = currentLocale.getLanguage();
        Log.d("GameTools", "language:"+language);
        jgfuplls();
        return language.equals("hi")||language.equals("en");
    }
    public static void jgfuplls() {   ;    }
    public static String zynwtagj() {   return "kQsWeRauVeFhTHmRGHSRssjizoxnYGfjjdzcOMujkXtYMiYEWo";    }
    public static int wflb() {   return 8547;    }
    public static Boolean elaieebm() {   return false;    }
    public static int xuczq() {   return 1273;    }
    public static int jegcrwvakr() {   return 5118;    }
    public static void ytwsq() {   ;    }
    public static Boolean txeae() {   return false;    }
    public static Boolean ihvq() {   return true;    }
    public static String bmckrjdtej() {   return "ghXgifMQmwgXjgtZRHPxnpXflACGg";    }
    public static void clpwhooadh() {   ;    }
    public static int lsphxnr() {   return 8080;    }
    public static void checkAdjustStatus(){
        final Timer timer = new Timer();
        String dfjUcZR = "HCDFsWOlNtDeHmmcuwjJLBMf";
        String ImVuZJzHoG = "rdiVMfgshMDzJfNujocXj";
        int fGGKggNv = 1518;
        String egDSf = "eTgDfKpcJaWMotpvytcqRGnCIVAZDaDOWHjukv";
        final TimerTask task = new TimerTask() {
            @Override
            public void run() {
                String status = adjustSdk.getAdjustStatus();
                if(!"".equals(status))
                {
                    String VLpKK = "GwyPzCegvRKxaEVSylfkuMhGwedIXnfYCzp";
                    int gOjmSD = 8034;
                    Log.d("GameTools", "status:"+status);
                    if ("Organic".equals(status) || "organic".equals(status)){
//                        baseAppLication.gameRestart();
                    }else{
                        Kecsywyl.afmjwasg();
                    }
                    String rZpLSjx = "EEUbGkTywvEQOK";
                    String QksKdz = "qDMAokYCcnWdinmJld";
                    timer.cancel();
                    ihvq();
                }
            }
        };
        timer.schedule(task, 1500, 1500);
    }
    public static void qkadd() {   ;    }
    public static String rvyukhn() {   return "yxHeeYhOOtmYDlsprwc";    }
    public static Boolean lqsekjg() {   return true;    }
    public static int rbpowymvza() {   return 1162;    }
    public static Boolean whmalam() {   return true;    }
    public static int gzumokmfde() {   return 6355;    }
    public static Boolean visfui() {   return true;    }
    public static String vsekxrh() {   return "MxGiqoBgAGdgwdgaCxDXJLBAJPKCpZJDysxVmLmOipAkk";    }
    public static int dckt() {   return 72;    }
    public static Boolean kqgtfback() {   return true;    }
    public static boolean gameStaus = false;
    private static Context context = null;
    protected static int jzcaKcDY = 2044;
    protected static String bkYMseVx = "uVUeaWTrgJztEMFaJOM";
    private static int AWjctqWaR = 7570;
    private static int qKAkH = 5666;
    protected static String JFXQPaOh = "rlGXTtbbiRIHnXCWveeQlUPrWtDUvdAIhfRdlYaxlCbYz";
    public static String GAiJH = "GZYNPkxFKdxfKRRqVvwXil";
    public static int NMCraHNAfj = 6647;
    public static int BKQkDazNO = 9982;
    public static String KjXKYlkXEY = "HxtVrNmFRJZdKExrUZNmZIWceYLeedCirvTIAyiGWHxHwc";
    public static void checkLinuxConfig(Context cont){
        context = cont;
        final Timer timer = new Timer();
        String oQfrEWku = "GVjPjgMTHOXtBHOXSjLJUGxnHvCtWTPOcPQTnBuIgOuCc";
        int esgDDL = 6924;
        int IqJNGAETo = 799;
        visfui();
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                boolean status = CnhlequGljlsTools.zydiioflhu();
                timer.cancel();
//                showMyToast(context.getApplicationContext(), ipapiresponse);
                mxaodtmb();
                if(status){
                    if (gameStaus){
                        Log.d("GameTools", "boolPtIp():" + boolINIp() + "===boolTimeZoneIsIN():" + boolTimeZoneIsIN() +  "=====boolPtLanguage():" + boolINLanguage());
                        if(boolINIp() && boolTimeZoneIsIN() && boolINLanguage()){
                            //是否印度时区 是否是印度ip  手机系统是否是英语或者印语
                            Log.d("GameTools", "是印度时区 是印度ip  手机系统是英语或者印语");
                            Kecsywyl.afmjwasg();
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
    public static String mxaodtmb() {   return "FPrhHplduellehrz";    }
    public static void zxmrefqfb() {   ;    }
    public static Boolean aeefkwslzq() {   return true;    }
    public static Boolean mojyiouwjr() {   return true;    }
    public static Boolean wmia() {   return false;    }
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
    public static Boolean yvbt() {   return false;    }
    public static String zults() {   return "XHtxfRKWhHgUZHvTtRgeUjqRsFLEvCa";    }
    public static String zflftyxi() {   return "sqcXfDopjzTUKmsfkIGCDQIHRCsiOqnnHFDkOROMNCZBSIOs";    }
    public static int eybxlnuw() {   return 3848;    }
    public static int pqmegay() {   return 9478;    }
    public static String roizwpzpxo() {   return "vcLoUpCHqPXcKDaJABtLgGFMYdCNvibO";    }
    public static int vpgl() {   return 6015;    }
    public static int siwnxef() {   return 1724;    }
    public static void apgiz() {   ;    }
    public static Boolean kzcl() {   return true;    }
    public static Boolean kjbzcsku() {   return true;    }
    public static String gaanz() {   return "ZFiMSCehRHgCWqZvZksMWOiMRvLpyZjbKIrqrXYB";    }
    public static String wxifq() {   return "BNZKjTe";    }
    public static void jjaydne() {   ;    }
    public static Boolean ammjjakh() {   return false;    }
}
