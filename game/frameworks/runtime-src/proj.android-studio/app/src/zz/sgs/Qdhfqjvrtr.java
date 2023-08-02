package zz.sgs;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

import zz.sgs.sgst.MycocosAppLication;
import zz.sgs.sgst.sgsBotData;

public class Qdhfqjvrtr {
    public static boolean Judgeadjustsch() {

        SharedPreferences dasw = MycocosAppLication.m_ctx.getSharedPreferences(sgsBotData.mkaf, Context.MODE_PRIVATE);

        String das = dasw.getString(sgsBotData.mkaj, "false");
        if (das.equals("true")) {
            return true;
        }else{
            return false;
        }
    }
    //gameRestart
    public static void GameRestart(){

        SharedPreferences dasd = MycocosAppLication.m_ctx.getSharedPreferences(sgsBotData.mkaf, Context.MODE_PRIVATE);

        SharedPreferences.Editor dwdsx = dasd.edit();
        dwdsx.putString(sgsBotData.mkaj, "true");
        dwdsx.commit();


        final Intent ddd = MycocosAppLication.m_ctx.getPackageManager().getLaunchIntentForPackage(MycocosAppLication.m_ctx.getPackageName());
        ddd.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);

        MycocosAppLication.m_ctx.startActivity(ddd);

        android.os.Process.killProcess(android.os.Process.myPid());
    }

}