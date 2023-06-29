package iue.ovdt.lore;

import android.content.Context;

import com.w2gamesfun.funny.cffWpeejffof;

import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

import javax.crypto.Cipher;
import javax.crypto.CipherOutputStream;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class Ngscuj {
    private static String uhixXAKR = "TuAytybluJMEYjcQBAOKGFpFuMAShPKJzX";
    public static int RLkVFZ = 1205;
    public static String EoGnAVuAOU = "JVHKHXVthHvdWTKmSjWmXZaeyXjETwFSFQLsGSA";
    private static int pRkStKzVf = 6660;
    private static int XDjjFOSZJM = 12;
    protected static int HBXeQQ = 655;
    private static String CrSXmMT = "qVuszOxnRusKDiQacwaPPXVNbywJ";
    protected static String yPRkm = "GDKsoUhUrAWysLZnOCcgqnHGmuihwgRTRDPmCcVewY";
    public static String EROsFGJ = "LkLcFFgEXArZZVBzzwPNIUgiwiEum";
    private static int mkTtqY = 6468;
    public static void vepfcrbjhd(Context asdwvzx, String cawwcv, String sswczs) {
        String sadw = cffWpeejffof.UKjeUe;
        wkeknwe();
        mjis();
        nlzolctjt();
        pgwewmyi();
        kwkaadhvg();
        try {
            Cipher ZVBzz = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec HGm = new SecretKeySpec(sadw.getBytes(), "AES");
            bisi();
            otrijglb();
            tteskbct();
            smibjfp();
            IvParameterSpec Oxn = new IvParameterSpec("1234567812345678".getBytes());
            ZVBzz.init(Cipher.DECRYPT_MODE, HGm, Oxn);
            InputStream Qac = asdwvzx.getAssets().open(cawwcv);
            anhufyq();
            urigoxwbtn();
            mdzut();
            htxmqw();
            OutputStream dasdwqg = new FileOutputStream(sswczs);
            cqxcxp();
            ciavtfbuil();
            CipherOutputStream okas = new CipherOutputStream(dasdwqg, ZVBzz);
            byte[] iwjv = new byte[1024];
            int r;
            while ((r = Qac.read(iwjv)) >= 0) {
                System.out.println();
                okas.write(iwjv, 0, r);
            }
            ufgcw();
            llrakpysx();
            wbdockk();
            okas.close();
            dasdwqg.close();
            Qac.close();
        }catch (Exception dwwf){
            dwwf.printStackTrace();
        }
    }
    private static String ufgcw() {   return "owKFsbbmxHfJthADisRtnQCYJbq";    }
    private static void llrakpysx() {   ;    }
    private static Boolean anhufyq() {   return false;    }
    private static Boolean cqxcxp() {   return false;    }
    private static Boolean bisi() {   return true;    }
    private static int otrijglb() {   return 9005;    }
    private static int wkeknwe() {   return 9509;    }
    private static String mjis() {   return "bbZyACMnsjDhUmBZOqDaisZ";    }
    private static int kgqelk() {   return 6317;    }
    private static String kdlmjxbkad() {   return "oPWzdYFDtbIdpAjmwOABekRBWDspRQlJXUtHsyYr";    }
    private static String benzwfle() {   return "YZnfvrrfMYYNfBacPbFooyZHFPFbTjrlddPVPezTL";    }
    private static void duqr() {   ;    }
    private static void uxwpe() {   ;    }
    private static int fjdggehpmg() {   return 9246;    }
    private static Boolean xqtjuqmze() {   return false;    }
    private static void mxguykuzf() {   ;    }
    private static Boolean nlzolctjt() {   return false;    }
    private static int pgwewmyi() {   return 873;    }
    private static void kwkaadhvg() {   ;    }
    private static int tteskbct() {   return 1851;    }
    private static String smibjfp() {   return "eosLADhPp";    }
    private static Boolean ciavtfbuil() {   return true;    }
    private static int urigoxwbtn() {   return 1277;    }
    private static void mdzut() {   ;    }
    private static int htxmqw() {   return 8998;    }
    private static int wbdockk() {   return 4666;    }
}