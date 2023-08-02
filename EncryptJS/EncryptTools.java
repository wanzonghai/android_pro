import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.security.Key;
import java.security.SecureRandom;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;
import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.KeyGenerator;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import java.io.BufferedWriter;
import java.io.OutputStreamWriter;

public class EncryptTools
{
    private static String zipFile = "D:\\rummy\\cocos-creator_update\\kenbuild\\jsb-link\\jsb-link.zip";
    private static String encryptFile = "D:\\rummy\\cocos-creator_update\\kenbuild\\jsb-link\\TuKlQ";
    //length:8
    private static String encryptPwd = "FXLQgCFU";
    private static String writeContent = "";

    public static void main(String[] args) {
        try {
            if(args.length > 0){
                System.out.println("args[0]" + args[0]);
                System.out.println("args[0]" + args[1]);
                System.out.println("args[0]" + args[2]);
                encryptPwd = args[0];
                zipFile = args[1];
                encryptFile = args[2];
                if(args.length >= 4){
                    writeContent = args[3];
                }
            }
            encryptDES(zipFile, encryptFile);
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    private static byte[] iv = {1,2,3,4,5,6,7,8};
    public static void encryptDES(String file, String destFile) throws Exception {
        IvParameterSpec zeroIv = new IvParameterSpec(iv);
        SecretKeySpec key = new SecretKeySpec(encryptPwd.getBytes(), "DES");
        Cipher cipher = Cipher.getInstance("DES/CBC/PKCS5Padding");
        cipher.init(Cipher.ENCRYPT_MODE, key, zeroIv);

        InputStream is = new FileInputStream(file);
        OutputStream out = new FileOutputStream(destFile);
        if(writeContent.length() > 0){
            out.write(writeContent.getBytes());
        }
        CipherInputStream cis = new CipherInputStream(is, cipher);
        byte[] buffer = new byte[1024];
        int r;
        while ((r = cis.read(buffer)) > 0) {
            out.write(buffer, 0, r);
        }
        cis.close();
        is.close();
        out.close();
    }
}
