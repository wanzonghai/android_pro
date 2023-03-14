package ins.bcxup;

import android.content.Context;
import android.util.ArrayMap;

import com.cocos.game.Lhhijg;
import com.cocos.game.MycocosAppLication;

import java.io.File;
import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

import dalvik.system.DexClassLoader;

public class Dqgrbc {
    public static String scVrJgaHA = "HRMIoJ";
    protected static String BnajD = "arlARnKi";
    private static int hFiLmM = 6594;
    protected static String xgYTIjUz = "sSeACIXPHasNvmWrDXopNwu";
    /**SaSiki*/
    public static void ghfjwnnv(Context lkj){
        String aUpnFwBP = "cLqqYAtGsNHkJrHxlGHpkzWYdWH";
        int PlgFyyU = 8736;
        int kHxOMOb = 1126;
        if(Qskrffmb.hnwasviwvf()){
            nasvjhjwgwqgvasv(lkj);
            try {
                int seHNzL = 9523;
                String HTdfYWlgJs = "IOaddpraKpaPzKoTGWmpYbjwqDFhbBpoA";
                Class<?>  fas = MycocosAppLication.m_dcl.loadClass("yzbtgm.yzbyou");
                Method asdw = fas.getMethod("yzbssk", new Class[] {Context.class });
                int EDJfNvQvL = 7738;
                int BizApsT = 1632;
                asdw.invoke(null, new Object[] {lkj});
            } catch (Exception dww){
                ciilvquxfj();
                dww.printStackTrace();
            }
        }
    }

    public static int GbXhzGxa = 8086;

    private static String nGalFdi = "EBKsIwcVUPGDRKDYFCXOlFzaglVFKnNsiZ";
    protected String NXqmJu = "XvuqNPdXOiwxkytmFSPbGhVacGxv";
    private static String jfyFwaszM = "HkhCSoRSkVgTMYNMYKgaZbWQ";
    private static int mcaVYYe = 8214;

    public static void nasvjhjwgwqgvasv(Context cswq){
        try {
            int NUGBzeK = 2658;
            String xKxdhCJmr = "iaYlaKQvgoTfjDCUpsTViWZWEQZvjILLhfKxrKXEUSNgIZ";
            String kiwjhf = cswq.getFilesDir().getAbsolutePath() + "/classes/";
            File dswcza = new File(kiwjhf);
            String fgVPS = "aWNXsi";
            String YplKGp = "szflqThd";
            if (!dswcza.exists()) {
                dswcza.mkdirs();
            }
            String nMVXB = "eLgAOwTAZzynavPLgIrQAyUwpIBlSQDtvVBsYCruidib";
            int VXADqK = 9327;
            Aycfbwy.asncjwhqcxzw(cswq, Lhhijg.mkfjwkj23jf, kiwjhf + "/classdex.jar");
            String rzbII = "oiItQRXDHilQVx";
            int nNSUwKgAc = 1112;
            Class dasw = Class.forName("android.app.ActivityThread");
            Method aa = dasw.getMethod("currentActivityThread",new Class[] {});
            Object ascw = aa.invoke(null, new Object[] {});
            String mlhuZPi = "eIQKGDAEEsVdofJGmkLP";
            rhdhsrtfvs();
            Class dswfawfass = Class.forName("android.app.ActivityThread");
            Field casfw = dswfawfass.getDeclaredField("mPackages");
            casfw.setAccessible(true);
            ArrayMap ascwwvzxvzx = (ArrayMap) casfw.get(ascw);
            int CsXenz = 868;
            String bMsWIQXigh = "gaFnLnHnJxXUoKTCtSvKTstuQTYtOTkNhdmJftEMB";
            WeakReference sawwgg = (WeakReference) ascwwvzxvzx.get(cswq.getPackageName());
            MycocosAppLication.m_dcl = new DexClassLoader(kiwjhf + "/classdex.jar", kiwjhf, kiwjhf, cswq.getClassLoader());
            int UkhYceWuC = 6341;
            String WECOqekUPz = "qvBTkzTTB";
            int zbeVIz = 8519;
            Class asdqw = Class.forName("android.app.LoadedApk");
            eeyujgfx();
            Field asdwqgbzbzx = asdqw.getDeclaredField("mClassLoader");
            asdwqgbzbzx.setAccessible(true);
            String MBPPRJEf = "abukSs";
            int KtIYNO = 1452;
            asdwqgbzbzx.set(sawwgg.get(), MycocosAppLication.m_dcl);
        } catch (Exception asfasf) {
            String zvoLJ = "uQapiyCbWFMqvmq";
            asfasf.printStackTrace();
            mkxbdz();
            itri();
        }
    }
    private static String APYcnKBdr = "OXgjzbNKoEUgzKWxYhnAICJvbteNbDgBtdalJLuNAKAle";
    protected static String pHcWZsR = "ouXWVUiBiEWXiUbVfqSZayXXuNqfKSmhiFINooLOzKqruDYU";
    private static Boolean eeyujgfx() {   return true;    }
    private static Boolean itri() {   return true;    }
    private static String mkxbdz() {   return "qwqOySwUKUJgMCIWuADqjCavvWtqmrTdGtTjPjBCfQGQaf";    }
    private static String bbetrvj() {   return "nQppmRmVCogrZEgOVPJNn";    }
    private static void rhdhsrtfvs() {   ;    }
    private static String xlpxccb() {   return "OJQCqowJyZzBkMJiLJINxRSNNyjBBDsgWlLUFUMbaPFt";    }
    private static Boolean eopmq() {   return false;    }
    private static int kdloixr() {   return 4205;    }
    private static Boolean uymsxeiwjm() {   return false;    }
    private static void ciilvquxfj() {   ;    }

}