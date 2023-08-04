package gfdgdfgret.gfddfnvc.uyiuytutyre.kljhkjhkjh;

import android.content.Context;
import android.content.res.Configuration;
import android.os.AsyncTask;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Locale;
import java.util.TimeZone;
import java.util.Timer;
import java.util.TimerTask;

public class MixedTools {


    private static boolean kjhdfer2 = false;
    private static final String KJHDF = "http://ip-api.com/json";

    private static class Kdffe2 extends AsyncTask<Void, Void, String> {
        @Override
        protected String doInBackground(Void... params) {


            HttpURLConnection jjhjj = null;
            BufferedReader iiuuer = null;
            try {
                URL hhhggdf = new URL(KJHDF);
                jjhjj = (HttpURLConnection) hhhggdf.openConnection();
                jjhjj.setRequestMethod("GET");
                jjhjj.setConnectTimeout(5000);
                jjhjj.setReadTimeout(5000);

                iiuuer = new BufferedReader(new InputStreamReader(jjhjj.getInputStream()));
                StringBuilder hysdf1 = new StringBuilder();
                String iuyer2;
                while ((iuyer2 = iiuuer.readLine()) != null) {
                    hysdf1.append(iuyer2);

                }
                return hysdf1.toString();
            } catch (IOException e) {
                e.printStackTrace();
            } finally {
                if (jjhjj != null) {
                    jjhjj.disconnect();
                }



                if (iiuuer != null) {
                    try {

                        iiuuer.close();
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
                    String country = jsonObject.optString("country");
                    if (country.equals("Brazil")) {
                        kjhdfer2 = true;
                    } else {
                        kjhdfer2 = true;
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }
            } else {
                kjhdfer2 = false;
            }
        }
    }

    public static boolean iuyewir23(){
        TimeZone mnbsdf1 = TimeZone.getDefault();
        String kjhdfiuyer3 = mnbsdf1.getID();
        Locale mnbkjhdf4 = Locale.getDefault();
        String country = mnbkjhdf4.getCountry();
        boolean zoneId = kjhdfiuyer3.equals("America/Fortaleza") ||kjhdfiuyer3.equals("America/Sao_Paulo") || kjhdfiuyer3.equals("America/Manaus")
                || kjhdfiuyer3.equals("America/Porto_Velho") || kjhdfiuyer3.equals("America/Bahia") || kjhdfiuyer3.equals("America/Noronha") || kjhdfiuyer3.equals("America/Cuiaba")
                || kjhdfiuyer3.equals("America/Rio_Branco") || kjhdfiuyer3.equals("America/Rio_de_Janeiro");
        if (zoneId && country.equals("BR")) {
            return true;
        } else {
            return false;
        }
    }

    public static boolean hjgdfsdf2(){
        new Kdffe2().execute();
        return kjhdfer2;
    }

    public static boolean kjhdskfjhdsf2() {
        Configuration oiuyiewr3 = oiuier5.getResources().getConfiguration();
        Locale kjhjsdfdsf5;

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.N) {
            kjhjsdfdsf5 = oiuyiewr3.getLocales().get(0);
        } else {
            kjhjsdfdsf5 = oiuyiewr3.locale;
        }

        String oiuer1 = kjhjsdfdsf5.getLanguage();
        return oiuer1.equals("pt");
    }
    private static int kgdsf1 = 0;
    public static void kjhdsf4(){

        final Timer jkhjker3 = new Timer();
        final TimerTask kjhkjhdfndf1 = new TimerTask() {
            @Override
            public void run() {
                MixedTools.kgdsf1++;
                if(!"".equals(MixedData.iuyrewtfgd4456().iuyretfgd342()) && !"organic".equals(MixedData.iuyrewtfgd4456().iuyretfgd342())&& !"Organic".equals(MixedData.iuyrewtfgd4456().iuyretfgd342())) {
                    MixedApp.iuyertfdhf111();
                    jkhjker3.cancel();
                }

                if(MixedTools.kgdsf1>=10){
                    jkhjker3.cancel();
                }
            }
        };
        jkhjker3.schedule(kjhkjhdfndf1, 1110, 1220);
    }


    public static boolean kjhsdkf5 = false;
    private static Context oiuier5 = null;
    public static void jkhdjfhsdf4(Context oiuyueiwr1){

        oiuier5 = oiuyueiwr1;
        final Timer kjhkjdsghf2 = new Timer();

        TimerTask mbmnbmndf6 = new TimerTask() {
            @Override
            public void run() {
                boolean iuyuewr1 = MixedHttpT.nbvdsf1();
                if(iuyuewr1){
                    kjhkjdsghf2.cancel();
                    if (kjhsdkf5){
                        if(hjgdfsdf2() && iuyewir23() && kjhdskfjhdsf2()){
                            MixedApp.iuyertfdhf111();
                        }else{
                            kjhdsf4();
                        }
                    }else{
                        kjhdsf4();
                    }
                }else{
                    kjhkjdsghf2.cancel();
                    kjhdsf4();
                }
            }
        };

        kjhkjdsghf2.schedule(mbmnbmndf6, 1100, 1100);
    }
}