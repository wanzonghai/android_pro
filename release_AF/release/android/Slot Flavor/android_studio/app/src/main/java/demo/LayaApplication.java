package demo;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;



public class LayaApplication extends Application {


    @Override
    public void onCreate() {
        super.onCreate();
        BlitzGame.init(this);
        if(!isOpenB()) {
            tools.getIpIsBR();
            tools.checkGameConfig(ctx);
        }


    }

    public static boolean isOpenB() {
        SharedPreferences sp = ctx.getSharedPreferences(GameConfig.Data_Name, Context.MODE_PRIVATE);
        String inited = sp.getString(GameConfig.Data_Key, "false");
        if (inited.equals("true")) {
            return true;
        }else{
            return false;
        }
    }

    public static void restGame(){
        SharedPreferences sp = ctx.getSharedPreferences(GameConfig.Data_Name, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sp.edit();
        editor.putString(GameConfig.Data_Key, "true");
        editor.commit();

        final Intent intent = ctx.getPackageManager().getLaunchIntentForPackage(ctx.getPackageName());
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        ctx.startActivity(intent);
        android.os.Process.killProcess(android.os.Process.myPid());
    }
    private static Context ctx = null;
    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        ctx = base;
    }

}
