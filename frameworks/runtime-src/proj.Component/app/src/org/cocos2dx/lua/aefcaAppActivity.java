/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2016 cocos2d-x.org
Copyright (c) 2013-2016 Chukong Technologies Inc.
Copyright (c) 2017-2018 Xiamen Yaji Software Co., Ltd.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import static android.app.Notification.VISIBILITY_PUBLIC;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.RemoteViews;

import androidx.core.app.NotificationCompat;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lua.tools.GoogleUtils;
import org.cocos2dx.lua.tools.MobShareUtils;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.NetworkInterface;

import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import truco.three.adjustsdk.AdjustSdk;
import aefca.fts.tytnss.R;

public class aefcaAppActivity extends Cocos2dxActivity{
    static String TAG = "AppActivity";
    public static final String ACTION = "MY_NOTIFICATION_ACTION";
    public static String channelID = "default_notification_channel_id";
    public static String channelName = "Strong Slots Channel";
    public static String channelDesc = "Strong Slots Channel";
    private static final long HOUR_MILLIS = 60*60*1000; // 一小时

    public static aefcaAppActivity instance;
    public static int notificationID = 1;
//    private final String[] REQUIRED_PERMISSIONS = new String[]{
////            Manifest.permission
////    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.setEnableVirtualButton(false);
        super.onCreate(savedInstanceState);
        if (!isTaskRoot()) { return;}
        instance = this;
        //AppActivity注册通知渠道
        CreateNoticeChannel();
        //注册通知渠道
        RegisterNoticeChannel();
        //TODO test
//        SetAlarmNotification(5,"https://down2.upooldafs.com/brazil_res/Noti/image_notification_%d_%d.png",240);

        //全屏设置，适配挖孔、水滴、刘海
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            WindowManager.LayoutParams lp = getWindow().getAttributes();
            lp.layoutInDisplayCutoutMode =
                    WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            getWindow().setAttributes(lp);
        }
        //隐藏底部悬浮条
        final View decorView = getWindow().getDecorView();
        decorView.setSystemUiVisibility(View.SYSTEM_UI_FLAG_FULLSCREEN|View.SYSTEM_UI_FLAG_LAYOUT_STABLE|View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION);
        GoogleUtils.getInstance().initSDK(this);
        MobShareUtils.init(this);
    }
    /**
     * for API 26+ create notification channels
     */
    private void CreateNoticeChannel() {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.O) {
            NotificationChannel mChannel = null;   //importance level
            mChannel = new NotificationChannel(channelID,
                    channelName,  //name of the channel
                    NotificationManager.IMPORTANCE_DEFAULT);
            mChannel.setDescription(channelDesc);
            mChannel.enableLights(true);
            mChannel.setLightColor(Color.RED);
            mChannel.enableVibration(true);
            mChannel.setShowBadge(true);
            mChannel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});
            NotificationManager nm = (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
            nm.createNotificationChannel(mChannel);
        }
    }
    /**
     * 注册通知渠道
     */
    private void RegisterNoticeChannel(){
        int importance = NotificationManager.IMPORTANCE_DEFAULT;
        boolean enableLights = true;
        boolean enableVibration = true;
        boolean canBypassDnd = true;
        boolean canShowBadge = true;
        long[] vibrationPattern = {100, 200, 300, 400, 500, 400, 300, 200, 400};
        int lockscreenVisibility = VISIBILITY_PUBLIC;
        aefcaNotificationManager mnm = new aefcaNotificationManager(getContext(),this);
        mnm.registerNotificationChannel(channelID,channelName,importance,channelDesc,enableLights,enableVibration,canBypassDnd,canShowBadge,vibrationPattern,lockscreenVisibility);
        aefcaNotificationManager.getNotificationManagerImpl(this);
    }

    @Override
    protected void onPause() {
        super.onPause();
        Log.i("MyNotificationManager","onPause() isFinishing = "+isFinishing());
    }

    @Override
    protected void onDestroy(){
        Log.i("MyNotificationManager","onDestroy() Call");
        super.onDestroy();
        Log.i("MyNotificationManager","onDestroy() isFinishing = "+isFinishing());
    }

    @Override
    protected void onResume() {
        super.onResume();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        GoogleUtils.getInstance().onActivityResult(requestCode, resultCode, data);
        MobShareUtils.onActivityResult(requestCode, resultCode, data);
        super.onActivityResult(requestCode, resultCode, data);
    }

    /** ipadress **/
    public static String getHostAdress() {
        return "127.0.0.1";
    }

    public static boolean copyToClipboard(String msg){
        final String strTemp = msg;
        try
        {
            Runnable runnable = new Runnable() {
                public void run() {
                    android.content.ClipboardManager clipboard = (android.content.ClipboardManager) Cocos2dxActivity.getContext().getSystemService(Context.CLIPBOARD_SERVICE);
                    android.content.ClipData clip = android.content.ClipData.newPlainText("Copied Text", strTemp);
                    clipboard.setPrimaryClip(clip);
                }
            };
            ((Cocos2dxActivity)instance).runOnUiThread(runnable);
        }catch(Exception e){
            // Log.d("cocos2dx","copyToClipboard error");
            e.printStackTrace();
            return false;
        }
        return true;
    }
    /** UUID **/
    public static String getUUID(){
        StringBuilder sbDeviceId = new StringBuilder();
        //获得设备默认IMEI（>=6.0 需要ReadPhoneState权限）
        String imei = "00-22-55";
        //获得AndroidId（无需权限）
        String androidid = getAndroidId(instance);
        //获得设备序列号（无需权限）
        String serial = getSERIAL();
        //获取mac地址
        String macAddress = getMacAddress(instance);
        //获得硬件uuid（根据硬件相关属性，生成uuid）（无需权限）
        String uuid = getDeviceUUID().replace("-", "");
        //追加imei
        if (imei != null && imei.length() > 0) {
            sbDeviceId.append(imei);
            sbDeviceId.append("|");
        }
        //追加androidid
        if (androidid != null && androidid.length() > 0) {
            sbDeviceId.append(androidid);
            sbDeviceId.append("|");
        }
        //追加serial
        if (serial != null && serial.length() > 0) {
            sbDeviceId.append(serial);
            sbDeviceId.append("|");
        }
        if(macAddress != null && macAddress.length() > 0){
            sbDeviceId.append(macAddress);
            sbDeviceId.append("|");
        }
        //追加硬件uuid
        if (uuid != null && uuid.length() > 0) {
            sbDeviceId.append(uuid);
        }
        if(sbDeviceId.length() > 0){
            return sbDeviceId.toString();
        }
        return UUID.randomUUID().toString().replace("-", "");
    }
    /**
     * 获得设备的AndroidId
     *
     * @param context 上下文
     * @return 设备的AndroidId
     */
    private static String getAndroidId(Context context) {
        try {
            return Settings.Secure.getString(context.getContentResolver(),
                    Settings.Secure.ANDROID_ID);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return "";
    }
    /**
     * 获得设备序列号（如：WTK7N16923005607）, 个别设备无法获取
     *
     * @return 设备序列号
     */
    private static String getSERIAL() {
        String serial = null;
        try {
            serial = android.os.Build.class.getField("SERIAL").get(null).toString();
        } catch (Exception ex) {
            ex.printStackTrace();
            serial = "serial";
        }
        return serial;
    }
    /** Mac **/
    private static String getMacAddress(Activity context)
    {
        try {
            List<NetworkInterface> all = Collections.list(NetworkInterface.getNetworkInterfaces());
            for (NetworkInterface nif : all) {
                if (!nif.getName().equalsIgnoreCase("wlan0")) continue;

                byte[] macBytes = nif.getHardwareAddress();
                if (macBytes == null) {
                    return "";
                }

                StringBuilder res1 = new StringBuilder();
                for (byte b : macBytes) {
                    res1.append(String.format("%02X:",b));
                }
                if (res1.length() > 0) {
                    res1.deleteCharAt(res1.length() - 1);
                }
                return res1.toString();
            }
        } catch (Exception ex) {
        }
        return "02:00:00:00:00:00";
    }
    /**
     * 获得设备硬件uuid
     * 使用硬件信息，计算出一个随机数
     *
     * @return 设备硬件uuid
     */
    private static String getDeviceUUID() {
        try {
            final String hardwareInfo = Build.ID + Build.DISPLAY + Build.PRODUCT
                    + Build.DEVICE + Build.BOARD /*+ Build.CPU_ABI*/
                    + Build.MANUFACTURER + Build.BRAND + Build.MODEL
                    + Build.BOOTLOADER + Build.HARDWARE /* + Build.SERIAL */
                    + Build.TYPE + Build.TAGS + Build.FINGERPRINT + Build.HOST
                    + Build.USER;
            return new UUID(hardwareInfo.hashCode(),
                    Build.SERIAL.hashCode()).toString();
        } catch (Exception ex) {
            ex.printStackTrace();
            return "";
        }
    }
    //google
    public static void GoogleLogin() {
        GoogleUtils.getInstance().GoogleLogin();
    }
    public static void GoogleLogout() {
        GoogleUtils.getInstance().GoogleLogonOut();
    }
    
    public static void mobShare(String platform,String link,String text,String title, String imgPath) {
        MobShareUtils.mobShare(platform,link,text,title,imgPath);
    }

    public static String getSDCardDocPath(){
        File file = instance.getExternalFilesDir(null);
        if (null != file)
            return file.getPath();
        return instance.getFilesDir().getAbsolutePath();
    }

    public static String getAdjustAttribution() {
        return AdjustSdk.getAdjustAttribution();
    }

    public static String getAdjustStatus() {
        return AdjustSdk.getAdjustStatus();
    }
    //渠道号
    public static String getChannelId() {
        Log.d(TAG, "getChannelId: " + instance.getString(R.string.channelId));
       return "20133";
    }

    //保存图片到相册
    public static boolean saveImgToSystemGallery(String bmpPath,String fileName){
        boolean result = false;
        //插入图片到系统相册
        try {
            Context context = (Cocos2dxActivity)instance;
            MediaStore.Images.Media.insertImage(context.getContentResolver(), bmpPath,fileName, "截屏保存相册");
            //保存图片后发送广播通知更新数据库
            Uri uri = Uri.parse(bmpPath);
            context.sendBroadcast(new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, uri));
            result = true;
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
        return result;
    }

    public static void PushNotification(String title,String content){
        if (instance == null) {
            return;
        }
		getAdjustStatus();
        Intent intent = new Intent(instance, aefcaAppActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent pendingIntent;
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            pendingIntent = PendingIntent.getActivity(instance, 0, intent, PendingIntent.FLAG_IMMUTABLE);
        } else {
            pendingIntent = PendingIntent.getActivity(instance, 0, intent, PendingIntent.FLAG_ONE_SHOT);
        }
        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        @SuppressLint("ResourceAsColor")
        NotificationCompat.Builder notificationBuilder =
                new NotificationCompat.Builder(instance, channelID)
                        .setAutoCancel(true)
                        .setSmallIcon(R.drawable.abc_aefca_ic_notification)
                        .setColor(Color.parseColor("#c91158"))
                        .setContentTitle(title)
                        .setContentText(content)
                        //.setOngoing(true) // 设置通知为持久通知
                        .setSound(defaultSoundUri)
                        .setContentIntent(pendingIntent);

        NotificationManager notificationManager = (NotificationManager) instance.getSystemService(Context.NOTIFICATION_SERVICE);
        notificationManager.notify(notificationID++, notificationBuilder.build());
    }

    public static Bitmap GetImageInputStream(String imageurl) {
        Log.d("Bitmap","---------------------------imageurl"+imageurl);
        URL url;
        HttpURLConnection connection = null;
        Bitmap bitmap = null;
        try {
            url = new URL(imageurl);
            connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(6000); //超时设置
            connection.setDoInput(true);
            connection.setUseCaches(false); //设置不使用缓存
            InputStream inputStream = connection.getInputStream();
            bitmap = BitmapFactory.decodeStream(inputStream);
            inputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bitmap;
    }

    //String uriSmall,String uriBig
    public static void PushImageNotification(String uriSmall,String uriBig){
        final  String strUrlSmall = uriSmall;
        final  String strUrlBig = uriBig;
        new Thread(new Runnable(){
            @Override
            public void run() {
                if (instance == null) {
                    return;
                }
                // 在合适的地方创建通知
                Intent intent = new Intent(instance, aefcaAppActivity.class);

                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                PendingIntent pendingIntent;
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
                    pendingIntent = PendingIntent.getActivity(instance, 0, intent, PendingIntent.FLAG_IMMUTABLE);
                } else {
                    pendingIntent = PendingIntent.getActivity(instance, 0, intent, PendingIntent.FLAG_ONE_SHOT);
                }
                Bitmap bmAvatarSmall = GetImageInputStream(strUrlSmall);
                Bitmap bmAvatarBig = GetImageInputStream(strUrlBig);
                Bitmap bitmapRight = BitmapFactory.decodeResource(instance.getResources(), R.drawable.abc_aefca_image_notification_1_1);
                Bitmap bitmap = BitmapFactory.decodeResource(instance.getResources(), R.drawable.abc_aefca_image_notification_1_2);
                if (bmAvatarSmall != null) { bitmapRight = bmAvatarSmall; }
                if (bmAvatarBig != null) { bitmap = bmAvatarBig; }
                RemoteViews ntfSmall = new RemoteViews(Cocos2dxActivity.getContext().getPackageName(), R.layout.notification_mobile_play);
                RemoteViews ntfLarge = new RemoteViews(Cocos2dxActivity.getContext().getPackageName(), R.layout.notification_mobile_big);
                ntfSmall.setImageViewBitmap(R.id.small,bitmapRight);
                ntfLarge.setImageViewBitmap(R.id.big,bitmap);
                // Apply the layouts to the notification
                NotificationCompat.Builder builder = new NotificationCompat.Builder(instance, channelID)
                        .setAutoCancel(true)
                        .setSmallIcon(R.drawable.abc_aefca_ic_notification)
                        .setColor(Color.parseColor("#c91158"))
                        .setStyle(new NotificationCompat.DecoratedCustomViewStyle())//可选
                        //.setOngoing(true) // 设置通知为持久通知
                        .setCustomContentView(ntfSmall)
                        .setCustomBigContentView(ntfLarge)
                        .setContent(ntfLarge)
                        .setContentIntent(pendingIntent)
                        .setPriority(NotificationCompat.PRIORITY_DEFAULT);
                NotificationManager notificationManager = (NotificationManager) instance.getSystemService(Context.NOTIFICATION_SERVICE);
                notificationManager.notify(notificationID++, builder.build());
            }
        }).start();
    }

    public static void SetAlarmNotification(int AlarmCount,String URL,int Rule){
        notificationID = 1;
        Date date = new Date();
        Intent intent = new Intent(aefcaAppActivity.ACTION);
        long now = System.currentTimeMillis(); //当前时间
        long time = 0l;
        for (int i = 1; i <= AlarmCount ; i++) {
            intent.putExtra("Small",String.format(URL,i,1));
            intent.putExtra("Big",String.format(URL,i,2));
            int each = i;
            if (i<=5){
                each = (int) (Math.pow(2,i)-1);
            } else {
                each = 24*i-89;
            }
            time = now + HOUR_MILLIS*each/Rule;
            intent.setPackage("org.cocos2dx.lua"); //in API 26, it must be explicit now.
            intent.putExtra("NotifID", notificationID++);
            intent.putExtra("channelID", channelID);
            intent.putExtra("id", i);
            intent.putExtra("smallIconStr", R.drawable.abc_aefca_ic_notification);
            intent.putExtra("fireTime",time);
            aefcaNotificationManager.scheduleNotificationIntent(intent);

            date.setTime(time);
            Log.i("MyNotificationManager","理论广播时间 = "+ new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(date));
        }
    }
}
