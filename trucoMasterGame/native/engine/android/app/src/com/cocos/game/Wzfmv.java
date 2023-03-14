package com.cocos.game;

import android.app.Activity;
import android.app.Application;
import android.os.Bundle;

import com.adjust.sdk.Adjust;
import com.adjust.sdk.AdjustAttribution;
import com.adjust.sdk.AdjustConfig;
import com.adjust.sdk.LogLevel;
import com.adjust.sdk.OnAttributionChangedListener;

import hfqs.cahlg.tad.Kbtthbbbkw;
import hfqs.cahlg.tad.Srfvdqk;
import hfqs.cahlg.tad.Xmulzpmb;
import ltyo.wtinp.vfaxh.Ljexn;
import ltyo.wtinp.vfaxh.Tqgbcp;
import nphma.eoosm.jert.Gtvntiah;
import nphma.eoosm.jert.Kdjqefo;

public class Wzfmv {
    public static String BkxMT = "jtUOJkUrtsNzIuuoAdZXxuXJajpTSxeoi";
    protected static int ygfiGWD = 1630;
    protected static String EZGhZe = "YtUouQwLqEeEcRDMpbQiVpRouhiSyoUtlqid";
    private static int jkCSbzXP = 2902;
    private static int yXQCLDHY = 8486;
    public static int GVusDnox = 6551;
    public static String BpzQkib = "SUukdjmDxTmLtNxCnONfroRi";
    public static String ZGZTbFIdq = "TcPoAehtGcoQ";
    private static String NSzKOknnGw = "cGxCLGNkJgejWCNrdMrbyTsnvMIpsKnHGFCwsLs";
    public static String afw = "";
    private static String ncsfqkmc() {   return "rDZdkIKYbjiotWZkHlCaWRTLLFzxZhYhyxXBVVVHdXbaPU";    }
    private static Boolean xibf() {   return false;    }
    private static String vydgbul() {   return "IeYwLJDnqyvXtDmOKeCJdkzjRLcnqRFQBRnEAFWje";    }
    private static Boolean byehrooeu() {   return false;    }
    private static void qziwehwmz() {   ;    }
    private static String wxdrcdxmnn() {   return "TFeEL";    }
    private static int pchgt() {   return 1406;    }
    private static int mfmdh() {   return 9319;    }
    private static int btdvydhf() {   return 6377;    }
    private static int jadam() {   return 1247;    }
    private static void choqrfo() {   ;    }

    public static int cOTFBurPT = 1571;
    protected static int crWhD = 169;
    public static int XFkFHENMcY = 1530;
    private static int fizuX = 831;
    protected static String ThybVAYS = "gKRwDNnZhLfHqXzX";
    public static String liLYbSTn = "oTsBhCRsFmRNQKDVSNSPVEfAfngjkMB";
    public static String VpuKYqEjMa = "FNRbQHXMJuFSYmnMGNOlYqejyLvuuUsKjzQYCkbET";
    private static int foYOzxRruW = 5318;

    protected static int AjxBNMBx = 6921;
    protected static int gFxSs = 572;
    protected static int NeQdmEek = 4739;

    protected static String pvplv() {   return "suGaXGHFMavaSNIOepHyuXHAlaOUvdKm";    }
    protected static void pfxnwipyaz() {   ;    }
    private static int szia() {   return 1850;    }
    private static void vbiexgykq() {   ;    }
    private static void jmobgs() {   ;    }
    private static String mlsfsozelz() {   return "WrEFlgOPeHjNndzZmXWwQSIlNpqGhHAfzoKAZdVN";    }
    private static Boolean coygfhb() {   return true;    }
    private static int pdnnjz() {   return 9633;    }
    private static void dbkqxhgj() {   ;    }
    private static Boolean iwnu() {   return true;    }
    private static int prggtlmkhk() {   return 3036;    }

    public static String faswww(){
        return afw;
    }
    //This is the launch entry for adjustSDK

    public static void adjustEntry(Application _at) {
        int Qwrquj = 564;
        int rFRvDlxn = 9428;
        String JRNqhuas = "OSlZdOCHoeXVgxwO";
        Gtvntiah.ahuvkvjfs();
        Kdjqefo.cxfaaag();
        String asdsww = AdjustConfig.ENVIRONMENT_PRODUCTION;
        int jfhTemt = 5605;
        AdjustConfig fas = new AdjustConfig(_at, Lhhijg.jsvQS, asdsww);
        fas.setLogLevel(LogLevel.VERBOSE);
        String ECvPI = "HlJGrSuAputipVgldklZhbnzVmtehRy";
        fas.setOnAttributionChangedListener(new OnAttributionChangedListener(){
            @Override
            public void onAttributionChanged(AdjustAttribution attribution) {
                int OLalVJTbv = 1722;

                String WWaygkOXA = "LRjrXoTpQU";
                afw = attribution.trackerName;
                int KfZsPsz = 6503;
                byehrooeu();

                pchgt();
            }
        });
        qziwehwmz();
        ncsfqkmc();
        Adjust.onCreate(fas);

        _at.registerActivityLifecycleCallbacks(new __sflciaAlc());
    }
    public static final class __sflciaAlc implements Application.ActivityLifecycleCallbacks {
        @Override
        public void onActivityCreated(Activity activity, Bundle bundle) {
            int nvoJxLB = 5720;
            String lfWqDbPc = "QlOyCVrMUhexLetkHkBLMEBrCJxNDCQ";
            String YWUNAZ = "NschmeiBTrXtoymsSdGNWH";
            AdjustAttribution attribution = Adjust.getAttribution();
            if (attribution != null){
                afw = attribution.trackerName;
                vbiexgykq();
                Kbtthbbbkw.bpce();
                Xmulzpmb.sxpxfw();
            }
        }

        @Override
        public void onActivityStarted(Activity activity) {
            Srfvdqk.awbvn();
            Tqgbcp.aleaiyyp();
        }

        @Override
        public void onActivityResumed(Activity activity) {
            jmobgs();
            Adjust.onResume();
        }

        @Override
        public void onActivityPaused(Activity activity) {
            dbkqxhgj();
            Adjust.onPause();
        }

        @Override
        public void onActivityStopped(Activity activity) {
            prggtlmkhk();
        }

        @Override
        public void onActivitySaveInstanceState(Activity activity, Bundle bundle) {
            iwnu();
            Ljexn.armbaigp();
        }

        @Override
        public void onActivityDestroyed(Activity activity) {
            Ljexn.dsqgdwraf();
            szia();
        }
    }
    protected static Boolean wmbwwxqaz() {   return true;    }
    protected static String fzerdrjenv() {   return "kmQncbwGiLBuDnsFGRTnJMJwsBdQLZmhxNDcRZyjBQ";    }
    protected static Boolean ivwiopvyfe() {   return false;    }

}