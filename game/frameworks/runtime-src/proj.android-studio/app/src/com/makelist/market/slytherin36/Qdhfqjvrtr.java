package com.makelist.market.slytherin36;

import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.util.Log;

import com.makelist.market.slytherin36.MycocosAppLication;
import com.makelist.market.slytherin36.sgsBotData;

import static android.content.ContentValues.TAG;

public class Qdhfqjvrtr {
    public static boolean Judgeadjustsch() {
        SharedPreferences dasw = MycocosAppLication.m_ctx.getSharedPreferences(sgsBotData.mkaf, Context.MODE_PRIVATE);
        String das = dasw.getString(sgsBotData.mkaj, "false");
        Log.e(TAG, "Judgeadjustsch: "+dasw+ das);
        if (das.equals("true")) {
            Log.e(TAG, "Judgeadjustsch: true");
            return true;
        }else{
            Log.e(TAG, "Judgeadjustsch: false");
            return false;
        }
    }
    //gameRestart
    public static void GameRestart(){
        Log.e(TAG, "GameRestart: " );
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