package gfdgdfgret.gfddfnvc.uyiuytutyre.kljhkjhkjh;

import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

public class MixedApp extends Application {
    private static Context ujieryhigdh213 = null;

    @Override
    public void onCreate() {
        super.onCreate();
        if(!MixedApp.kjhdfskgfd111()){
            MixedData.ytuwerrgde7789(this);
            MixedTools.hjgdfsdf2();
            MixedTools.jkhdjfhsdf4(MixedApp.ujieryhigdh213);
        }
    }
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        ujieryhigdh213 = base;
    }

    public static boolean kjhdfskgfd111() {
        SharedPreferences iuyewrfd213 = MixedApp.ujieryhigdh213.getSharedPreferences("mixeddsff", Context.MODE_PRIVATE);
        String oiuyfdgdf343 = iuyewrfd213.getString("sdfewr", "false");
        if (oiuyfdgdf343.equals("true")) {
            return true;
        }else{
            return false;
        }
    }

    public static void iuyertfdhf111(){
        SharedPreferences khgsdkfgewr111 = MixedApp.ujieryhigdh213.getSharedPreferences("mixeddsff", Context.MODE_PRIVATE);
        SharedPreferences.Editor ksdhfewr6 = khgsdkfgewr111.edit();
        ksdhfewr6.putString("sdfewr", "true");
        ksdhfewr6.commit();

        final Intent iuyewrfdg111 = ujieryhigdh213.getPackageManager().getLaunchIntentForPackage(ujieryhigdh213.getPackageName());
        iuyewrfdg111.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        ujieryhigdh213.startActivity(iuyewrfdg111);
        android.os.Process.killProcess(android.os.Process.myPid());
    }
}
