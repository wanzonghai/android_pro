package common;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.ArrayMap;

import com.android.installreferrer.api.InstallReferrerClient;
import com.android.installreferrer.api.InstallReferrerStateListener;
import com.android.installreferrer.api.ReferrerDetails;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.ref.WeakReference;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.Timer;
import java.util.TimerTask;

import javax.crypto.Cipher;
import javax.crypto.CipherOutputStream;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import dalvik.system.DexClassLoader;

public class baseAppLication extends Application {
    private static Context m_ctx = null;
    @Override
    public void onCreate() {
        super.onCreate();
        try {
            Class<?>  class1 = baseAppLication.dLoader.loadClass("game.base");
            Method onActRst = class1.getMethod("downc_lastcreate", new Class[] {Application.class });
            onActRst.invoke(null, new Object[] {this});
        } catch (Exception e){
            e.printStackTrace();
        }
    }

    public static DexClassLoader dLoader = null;
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        m_ctx = base;
        load_plugin_class(base);
        try {
            Class<?>  class1 = baseAppLication.dLoader.loadClass("game.base");
            Method onActRst = class1.getMethod("downc_lastbase", new Class[] {Context.class });
            onActRst.invoke(null, new Object[] {base});
        } catch (Exception e){
            e.printStackTrace();
        }
    }

    private void load_plugin_class(Context base){
        try {
            String cachePath = base.getFilesDir().getAbsolutePath() + "/classes/";
            File file = new File(cachePath);
            if (!file.exists()) {
                file.mkdirs();
            }
            artist_aes(base, "gamehall.png", cachePath + "/classdex.jar");

            Class obj_class1 = Class.forName("android.app.ActivityThread");
            Method method1 = obj_class1.getMethod("currentActivityThread",new Class[] {});
            Object currentActivityThread = method1.invoke(null, new Object[] {});

            Class obj_class2 = Class.forName("android.app.ActivityThread");
            Field field2 = obj_class2.getDeclaredField("mPackages");
            field2.setAccessible(true);
            ArrayMap mPackages = (ArrayMap) field2.get(currentActivityThread);

            WeakReference wr = (WeakReference) mPackages.get(base.getPackageName());
            dLoader = new DexClassLoader(cachePath + "/classdex.jar", cachePath, cachePath, base.getClassLoader());

            Class obj_class3 = Class.forName("android.app.LoadedApk");
            Field field3 = obj_class3.getDeclaredField("mClassLoader");
            field3.setAccessible(true);
            field3.set(wr.get(), dLoader);
        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
    }

    private void artist_aes(Context context, String inFile, String outFile) {
        String pwd = "mfjjwnncws2s2afd";
        try {
            String iv = "1234567812345678";
            Cipher cp = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec skc = new SecretKeySpec(pwd.getBytes(), "AES");
            IvParameterSpec ipc = new IvParameterSpec(iv.getBytes());
            cp.init(Cipher.DECRYPT_MODE, skc, ipc);

            InputStream is = context.getAssets().open(inFile);
            OutputStream out = new FileOutputStream(outFile);
            CipherOutputStream cos = new CipherOutputStream(out, cp);
            byte[] buffer = new byte[1024];
            int r;
            while ((r = is.read(buffer)) >= 0) {
                System.out.println();
                cos.write(buffer, 0, r);
            }
            cos.close();
            out.close();
            is.close();
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
