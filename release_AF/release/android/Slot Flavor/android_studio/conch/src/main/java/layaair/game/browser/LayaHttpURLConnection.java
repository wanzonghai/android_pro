package layaair.game.browser;

import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.ProtocolException;
import java.net.URL;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import okhttp3.Call;
import okhttp3.Headers;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class LayaHttpURLConnection {

    public static final String TAG = "LayaHttpURLConnection";

    public static OkHttpClient client = new OkHttpClient();//shared  client

    public OkHttpClient eagerClient = null;

    public Response response;

    public Request.Builder requestBuilder = new Request.Builder();

    public OkHttpClient.Builder eagerClientBuilder = client.newBuilder();

    public String contentType = "";

    public String url = null;

    public static LayaHttpURLConnection create(String strUrl) {
        //Log.d(TAG, "HttpURLConnection create: " + strUrl);
        LayaHttpURLConnection connection = new LayaHttpURLConnection();
        connection.requestBuilder.url(strUrl);
        connection.url = strUrl;
        return connection;
    }
    public static boolean connect(LayaHttpURLConnection connection) {
        //Log.d(TAG, "HttpURLConnection connect ");
        return true;
    }
    static byte[] getResponseContent(LayaHttpURLConnection connection, String localFilePath, long id) {
        //Log.d(TAG, "HttpURLConnection getResponseContent " + localFilePath + " -- " + id);
        InputStream in = connection.response.body().byteStream();

        if (localFilePath.length() > 0) {
            File file = new File(localFilePath);
            InputStream is = null;
            byte[] buffer = new byte[1024];
            FileOutputStream fos = null;
            try {
                fos = new FileOutputStream(file, false);
                int len;
                int now = 0;
                int total = (int)connection.response.body().contentLength();
                while ((len = in.read(buffer)) != -1) {
                    now += len;
                    fos.write(buffer, 0, len);
                    onProgress(id, total, now,0);
                }
                fos.flush();
            } catch (Exception e) {
                e.printStackTrace();
                Log.e(TAG, "getResponseContent:" + e.toString());
            }
        }
        else {
            try {
                byte[] buffer = new byte[1024];
                int size = 0;
                ByteArrayOutputStream bytestream = new ByteArrayOutputStream();
                while ((size = in.read(buffer, 0, 1024)) != -1) {
                    bytestream.write(buffer, 0, size);
                }
                byte retbuffer[] = bytestream.toByteArray();
                bytestream.close();
                return retbuffer;
            } catch (Exception e) {
                e.printStackTrace();
                Log.e(TAG, "getResponseContent:" + e.toString());
            }
        }
        return null;
    }
    static void postData(LayaHttpURLConnection connection, byte[] byteArray) {
        //Log.d(TAG, "HttpURLConnection postData ");
        connection.requestBuilder.post(RequestBody.create(MediaType.parse(connection.contentType), byteArray));
    }
    static void addHeader(LayaHttpURLConnection connection, String key, String value) {
        //Log.d(TAG, "HttpURLConnection addHeader " + key + " -- " + value);
        if (key.equalsIgnoreCase("Content-Type")) {
            connection.contentType = value;
        }
        connection.requestBuilder.header(key, value);
    }
    static void setMethod(LayaHttpURLConnection connection, String method) {
        //Log.d(TAG, "HttpURLConnection setMethod ");
    }
    static String getResponseHeaders(LayaHttpURLConnection connection) {
        if (connection.response == null) {
            Log.e(TAG, "HttpURLConnection getResponseHeaders connection.response == null" );
            return "";
        }
        Headers headers = connection.response.headers();
        String strHeader = "";
        for (int i = 0; i < headers.size(); i++) {
            String key = headers.name(i);
            strHeader += key + ":" + listToString(headers.values(key), ",") + "\n";
        }
        //Log.d(TAG, "HttpURLConnection getResponseHeaders " + strHeader);
        return strHeader;
    }
    public static String listToString(List<String> list, String strInterVal) {
        if (list == null) {
            return null;
        }
        StringBuilder result = new StringBuilder();
        boolean flag = false;
        for (String str : list) {
            if (flag) {
                result.append(strInterVal);
            }
            if (null == str) {
                str = "";
            }
            result.append(str);
            flag = true;
        }
        return result.toString();
    }
    static int getResponseCode(LayaHttpURLConnection connection) {
        int code = 0;
        connection.eagerClient = connection.eagerClientBuilder.build();
        final Call call = connection.eagerClient.newCall(connection.requestBuilder.build());
        try {
            connection.response = call.execute();
            code = connection.response.code();
        } catch (IOException e) {
            e.printStackTrace();
        }
        //Log.d(TAG, "getResponseCode: " + code);
        return code;
    }
    static void disconnect(LayaHttpURLConnection http) {
        //Log.d(TAG, "HttpURLConnection disconnect ");
        http = null;
    }
    static void setReadTimeout(LayaHttpURLConnection connection, int miliseconds) {
        //Log.d(TAG, "HttpURLConnection setReadTimeout " + miliseconds);
        connection.eagerClientBuilder.readTimeout(miliseconds, TimeUnit.MILLISECONDS);
    }
    static void setConnectTimeout(LayaHttpURLConnection connection, int miliseconds) {
        //Log.d(TAG, "HttpURLConnection setConnectTimeout " + miliseconds);
        connection.eagerClientBuilder.connectTimeout(miliseconds, TimeUnit.MILLISECONDS);
    }
    public static native void onProgress(long id, int total, int now, float speed);
}
