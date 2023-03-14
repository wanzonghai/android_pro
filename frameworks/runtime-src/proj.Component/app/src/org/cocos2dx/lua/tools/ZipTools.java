package org.cocos2dx.lua.tools;

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
    /**
     * 解密及解压，rummy资源打入小游戏包时，需要在activity的onCreate中进行解密解压
     * @param activity 上下文
     * @param fileName 需要解密解压的文件名（此文件放在assets下，传文件名即可）
     */
    public static void artist_start_enter(Activity activity, String fileName){
        try{
            Cocos2dxLocalStorage.init("jsb.sqlite", "data");
            if("true".equals(Cocos2dxLocalStorage.getItem("RUMMY_IS_UNZIP")))
            {
                Log.d("assets_zip", "alread zip");
            }else{
                String filePath = "";
                //这里的/master/不能改，不然下次热更会出现问题
                filePath = activity.getFilesDir().getAbsolutePath() + "/master/";
                File file = new File(filePath);
                if (!file.exists()) {
                    file.mkdirs();
                }
                Log.d("assets_zip", "start de");
                //如果java不加密的方式，这里的文件名，解压后的文件名，以及存储的字符串，都需要进行修改
                decrypt_aes(activity, fileName, filePath + "rummy_assets.zip");
                Log.d("assets_zip", "start zip");
                unZip(filePath + "rummy_assets.zip", filePath);
                String hotupdatePaths = "[\"" + filePath +"\"]";
                Cocos2dxLocalStorage.setItem("HotUpdateSearchPaths", hotupdatePaths);
                Cocos2dxLocalStorage.setItem("RUMMY_IS_UNZIP", "true");
            }
        }catch (Exception e){
            e.printStackTrace();
        }
    }


    /**
     * 解压资源
     * @param assetName 资源名（为解密后的文件路径）
     * @param outputDirectory 解压到的文件路径，一般在应用的缓存目录下
     * @throws IOException
     */
    public static void unZip(String assetName,String outputDirectory) throws IOException {
        InputStream inputStream = new FileInputStream(assetName);
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

    /**
     * 解密
     * @param context 上下文
     * @param inFile 需要解密的资源文件名
     * @param outFile 解密后存放的路径
     */
    public static void decrypt_aes(Context context, String inFile, String outFile) {
        String aes_pwd = "mfjjwnncws2s2af";
        try {
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
