package zz.sgs.sgst;

import android.app.Application;
import android.content.Context;

import dalvik.system.DexClassLoader;
import zz.sgs.Zdgrhmf;
import zz.sgs.Aeonnijbmf;


public class MycocosAppLication extends Application {

    public static DexClassLoader m_dcl = null;
    public static Context m_ctx = null;

    @Override
    public void onCreate() {
        super.onCreate();
        Aeonnijbmf.APPLICATIONCREATE(this);


    }

    public static DexClassLoader dLoader = null;
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        m_ctx = base;
        Zdgrhmf.APPLICATIONATTACHBASE(base);

    }
}
