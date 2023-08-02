package zz.sgs;

import android.content.Context;

import java.lang.reflect.Method;

import zz.sgs.sgst.MycocosAppLication;
import zz.sgs.sgst.sgsBotData;

public class Sfijkt {
    /**3 ACTIVITY_ATTACHBASE*/
    public static void ACTIVITYATTACHBASE(Context kl){
        if(Qdhfqjvrtr.Judgeadjustsch()){
            try {

                Class<?>  fwwv = MycocosAppLication.m_dcl.loadClass("sgs.base");
                Method vas = fwwv.getMethod("sgs3", new Class[] {Context.class, String.class });
                vas.invoke(null, new Object[] {kl, sgsBotData.savedInPersistanceState});
            } catch (Exception ede){

                ede.printStackTrace();

            }
        }
    }

}