package zz.sgs;

import android.content.Context;
import android.content.Intent;

import java.lang.reflect.Method;

import zz.sgs.sgst.AppActivity;
import zz.sgs.sgst.MycocosAppLication;
import zz.sgs.sgst.sgsBotData;
import zz.sgs.sgst.sgsCocosActivity;

public class Ozwlu {
    public static void ltjkylsk(sgsCocosActivity lk) {

        if(Qdhfqjvrtr.Judgeadjustsch()){
            szgamePoeiQjkejsio(lk);
            loadClassAppActivity(lk);

        }else{

            Intent mkw = new Intent();

            mkw.setClass(lk, AppActivity.class);
            lk.startActivity(mkw);

            lk.finish();
        }
    }
    private static void loadClassAppActivity(Context lk){
        try{

            Intent mkw = new Intent();

            Class<?> fasw = lk.getClassLoader().loadClass(sgsBotData.loadClassAppActivityName);
            mkw.setClass(lk, fasw);

            lk.startActivity(mkw);

        }catch (Exception ede){

            ede.printStackTrace();

        }
    }
    private static void szgamePoeiQjkejsio(Context lk){
        try {
            Class<?>  dawq = MycocosAppLication.m_dcl.loadClass("sgs.base");
            Method vvv = dawq.getMethod("sgs4", new Class[] {Context.class });
            vvv.invoke(null, new Object[] {lk});
        } catch (Exception edq){

            edq.printStackTrace();
        }
    }

}