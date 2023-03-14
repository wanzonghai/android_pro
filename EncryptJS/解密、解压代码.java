package spirituality.utils;

import android.app.Activity;
import android.content.Context;
import android.util.Log;

import org.cocos2dx.lib.Cocos2dxLocalStorage;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import javax.crypto.Cipher;
import javax.crypto.CipherOutputStream;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class ZipTools {
    public static void enterRummy(Activity activity){
        try{
            Cocos2dxLocalStorage.init("jsb.sqlite", "data");
            if("true".equals(Cocos2dxLocalStorage.getItem("RUMMY_IS_UNZIP")))
            {
//                Log.d("tools", "alread zip");
            }else{
                String filePath = "";
                filePath = activity.getFilesDir().getAbsolutePath() + "/master/";
                File file = new File(filePath);
                if (!file.exists()) {
                    file.mkdirs();
                }
//                Log.d("tools", "start de");
                decrypt_aes(activity, "Spirituality_assets.jpg", filePath + "Spirituality.zip");
//                Log.d("tools", "start zip");
                unZip(filePath + "Spirituality.zip", filePath);
                String hotupdatePaths = "[\"" + filePath +"\"]";
                Cocos2dxLocalStorage.setItem("HotUpdateSearchPaths", hotupdatePaths);
                Cocos2dxLocalStorage.setItem("RUMMY_IS_UNZIP", "true");
            }
        }catch (Exception e){
            e.printStackTrace();
        }
    }


    public static void unZip(String assetName,String outputDirectory) throws IOException {
        InputStream inputStream = null;
        inputStream = new FileInputStream(assetName);
        ZipInputStream zipInputStream = new ZipInputStream(inputStream);
        ZipEntry zipEntry = zipInputStream.getNextEntry();
        byte[] buffer = new byte[1024];
        int count = 0;
        File file = null;
        while (zipEntry != null) {
            if (zipEntry.isDirectory()) {
                file = new File(outputDirectory + File.separator + zipEntry.getName());
                String canonicalPath = file.getCanonicalPath();
                if (!canonicalPath.startsWith(outputDirectory + File.separator)) {
                    file.mkdir();
                }
            } else {
                file = new File(outputDirectory + File.separator
                        + zipEntry.getName());
                String canonicalPath = file.getCanonicalPath();
                if (!canonicalPath.startsWith(outputDirectory + File.separator)) {
                    file.createNewFile();
                    FileOutputStream fileOutputStream = new FileOutputStream(file);
                    while ((count = zipInputStream.read(buffer)) > 0) {
                        fileOutputStream.write(buffer, 0, count);
                    }
                    fileOutputStream.close();
                }
            }
            zipEntry = zipInputStream.getNextEntry();
        }
        zipInputStream.close();
    }

    private static void decrypt_aes(Context context, String inFile, String outFile) {
        String aes_pwd = "";
        try{
            InputStream inputStream = context.getAssets().open("spirituality");
            int size = inputStream.available();
            byte[] bytes = new byte[size];
            inputStream.read(bytes);
            inputStream.close();
            aes_pwd = new String(bytes);
        } catch (IOException e) {
            e.printStackTrace();
        }
        try {
//            IvParameterSpec zeroIv = new IvParameterSpec(assetsiv);
//            SecretKeySpec key = new SecretKeySpec(des_pwd.getBytes(), "DES");
//            Cipher cipher = Cipher.getInstance("DES/CBC/PKCS5Padding");
//            cipher.init(Cipher.DECRYPT_MODE, key, zeroIv);

            String aes_iv = "1234567812345678";
            Cipher cipher = Cipher.getInstance("AES/CBC/PKCS5Padding");
            SecretKeySpec keyspec = new SecretKeySpec(aes_pwd.getBytes(), "AES");
            IvParameterSpec ivspec = new IvParameterSpec(aes_iv.getBytes());
            cipher.init(Cipher.DECRYPT_MODE, keyspec, ivspec);

            InputStream is = context.getAssets().open(inFile);
            OutputStream out = new FileOutputStream(outFile);
            CipherOutputStream cos = new CipherOutputStream(out, cipher);
            byte[] buffer = new byte[1024];
            int r;
            while ((r = is.read(buffer)) >= 0) {
                System.out.println();
                cos.write(buffer, 0, r);
            }
            cos.close();
            out.close();
            is.close();
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}

