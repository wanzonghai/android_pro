import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

public class EncryptTools_AES
{
    private static final String KEY_ALGORITHM = "AES";
    private static final String DEFAULT_CIPHER_ALGORITHM = "AES/CBC/PKCS5Padding";
    private static final String iv = "1234567812345678";
    private static String encryptPwd = "";
    private static String zipFile = "";
    private static String encryptFile = "";
    private static String writeContent = "";

    public static void main(String[] args) {
        try {
            if(args.length > 0){
                encryptPwd = args[0];
                zipFile = args[1];
                encryptFile = args[2];
                if(args.length >= 4){
                    writeContent = args[3];
                }
            }
            encryptAES(zipFile, encryptFile);
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    public static void encryptAES(String file, String destFile){
        try {
            Cipher cipher = Cipher.getInstance(DEFAULT_CIPHER_ALGORITHM);
            SecretKeySpec keyspec = new SecretKeySpec(encryptPwd.getBytes(), KEY_ALGORITHM);
            IvParameterSpec ivspec = new IvParameterSpec(iv.getBytes());
            cipher.init(Cipher.ENCRYPT_MODE, keyspec, ivspec);

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

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
