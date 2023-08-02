package org.cocos2dx.lua;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Color;

import android.graphics.drawable.Drawable;
import android.os.Build;

import android.os.Handler;
import android.util.Log;
import android.widget.RemoteViews;
import androidx.core.app.NotificationCompat;
import aefca.fts.tytnss.R;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.target.CustomTarget;
import com.bumptech.glide.request.transition.Transition;


public class aefcaNotificationCallback implements NotificationCallback{
    public static String channelID = "default_notification_channel_id";
    public static String channelName = "Truco King Channel";
    public static String channelDesc = "Truco King Channel";
    private Context _context;
    private String _pSmall;
    private String _pBig;
    private long _when;
    @Override
    public void onSendNotification(Context context,Intent intent){
        Log.d("MyNotificationManager", "onSendNotification: 11111");
        String pSmall = intent.getStringExtra("Small");
        String pBig = intent.getStringExtra("Big");
        long when = intent.getLongExtra("fireTime",System.currentTimeMillis());
        saveImg1(context,pSmall);
        saveImg2(context,pBig);
//        PushImageNotification(context,pSmall,pBig,when);
        _context = context;
        _when = when;
        _pSmall = pSmall;
        _pBig = pBig;
        Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                PushImageNotification(_context,_pSmall,_pBig,_when);
            }
        }, 3000);
    }

//    public void PushImageNotification(final Context context, String uriSmall, String uriBig,final long when){
//        final  String strUrlSmall = uriSmall;
//        final  String strUrlBig = uriBig;
//        new Thread(new Runnable(){
//            @Override
//            public void run() {
//                if (context == null) {
//                    return;
//                }
//                // 在合适的地方创建通知
//                Intent intent = new Intent(context, sdAppActivity.class);
//
//                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
//                PendingIntent pendingIntent;
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
//                    pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE);
//                } else {
//                    pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_ONE_SHOT);
//                }
//                NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
//                String channelDescription = "This is image notification channel";
//                // 检查 Android 版本是否大于等于 Android 8.0（Oreo）
//                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//                    // 创建通知渠道
//                    int importance = NotificationManager.IMPORTANCE_DEFAULT;
//                    NotificationChannel notificationChannel = new NotificationChannel(channelID, channelName, importance);
//                    notificationChannel.setDescription(channelDescription);
//                    notificationManager.createNotificationChannel(notificationChannel);
//                }
//                Log.d("MyNotificationManager", "PushImageNotification 1");
//                Bitmap bmAvatarSmall = GetImageInputStream(strUrlSmall);
//                Bitmap bmAvatarBig = GetImageInputStream(strUrlBig);
//                Log.d("MyNotificationManager", "PushImageNotification 2");
//                Bitmap bitmapRight = BitmapFactory.decodeResource(context.getResources(), R.drawable.image_notification_1_1);
//                Bitmap bitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.image_notification_1_2);
//                Log.d("MyNotificationManager", "bmAvatarSmall:" + bmAvatarSmall);
//                Log.d("MyNotificationManager", "bmAvatarBig:" + bmAvatarBig);
//                if (bmAvatarSmall != null) { bitmapRight = bmAvatarSmall; }
//                if (bmAvatarBig != null) { bitmap = bmAvatarBig; }
//                Log.d("MyNotificationManager", "PushImageNotification 3");
//                RemoteViews ntfSmall = new RemoteViews(context.getPackageName(), R.layout.notification_mobile_play);
//                RemoteViews ntfLarge = new RemoteViews(context.getPackageName(), R.layout.notification_mobile_big);
//                Log.d("MyNotificationManager", "ntfSmall:" + ntfSmall);
//                Log.d("MyNotificationManager", "ntfLarge:" + ntfLarge);
//                ntfSmall.setImageViewBitmap(R.id.small,bmAvatarSmall);
//                ntfLarge.setImageViewBitmap(R.id.big,bitmap);
//                Log.d("MyNotificationManager", "PushImageNotification 4");
//                // Apply the layouts to the notification
//                NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelID)
//                        .setAutoCancel(true)
//                        .setSmallIcon(R.drawable.ic_notification)
//                        .setColor(Color.parseColor("#c91158"))
//                        .setStyle(new NotificationCompat.DecoratedCustomViewStyle())//可选
////                        .setOngoing(true) // 设置通知为持久通知
//                        .setCustomContentView(ntfSmall)
//                        .setCustomBigContentView(ntfLarge)
//                        .setContent(ntfLarge)
//                        .setWhen(when)
//                        .setContentIntent(pendingIntent)
//                        .setPriority(NotificationCompat.PRIORITY_DEFAULT);
//                notificationManager.notify(sdAppActivity.notificationID++, builder.build());
//            }
//        }).start();
//    }

    private static Bitmap bitmap1;
    private static Bitmap bitmap2;

    public static void saveImg1(final Context context,String uriSmall){
        Glide.with(context)
                .asBitmap()
                .load(uriSmall)
                .into(new CustomTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(Bitmap resource, Transition<? super Bitmap> transition) {
                        // set image to notification
//                        setNotificationImage(resource);
                        bitmap1 = resource;
                        Log.d("MyNotificationManager", "saveImg1:" + bitmap1);
                    }

                    @Override
                    public void onLoadCleared(Drawable placeholder) {

                    }
                });
    }

    public static void saveImg2(final Context context,String uriBig){
        Glide.with(context)
                .asBitmap()
                .load(uriBig)
                .into(new CustomTarget<Bitmap>() {
                    @Override
                    public void onResourceReady(Bitmap resource, Transition<? super Bitmap> transition) {
                        // set image to notification
                        bitmap2 = resource;
                        Log.d("MyNotificationManager", "saveImg2:" + bitmap2);
                    }

                    @Override
                    public void onLoadCleared(Drawable placeholder) {

                    }
                });
    }
    public void PushImageNotification(final Context context, String uriSmall, String uriBig,final long when){
        final  String strUrlSmall = uriSmall;
        final  String strUrlBig = uriBig;

        new Thread(new Runnable(){
            @Override
            public void run() {
                if (context == null) {
                    return;
                }
                // 在合适的地方创建通知
                Intent intent = new Intent(context, aefcaAppActivity.class);

                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                PendingIntent pendingIntent;
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_IMMUTABLE);
                } else {
                    pendingIntent = PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_ONE_SHOT);
                }
                NotificationManager notificationManager = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
                String channelDescription = "This is image notification channel";
                // 检查 Android 版本是否大于等于 Android 8.0（Oreo）
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    // 创建通知渠道
                    int importance = NotificationManager.IMPORTANCE_DEFAULT;
                    NotificationChannel notificationChannel = new NotificationChannel(channelID, channelName, importance);
                    notificationChannel.setDescription(channelDescription);
                    notificationManager.createNotificationChannel(notificationChannel);
                }
                Log.d("MyNotificationManager", "PushImageNotification 1");
                RemoteViews ntfSmall = new RemoteViews(context.getPackageName(), R.layout.notification_mobile_play);
                RemoteViews ntfLarge = new RemoteViews(context.getPackageName(), R.layout.notification_mobile_big);
                Log.d("MyNotificationManager", "bitmap1:" + bitmap1);
                Log.d("MyNotificationManager", "bitmap2:" + bitmap2);
                ntfSmall.setImageViewBitmap(R.id.small,bitmap1);
                ntfLarge.setImageViewBitmap(R.id.big,bitmap2);
                Log.d("MyNotificationManager", "PushImageNotification 4");
                // Apply the layouts to the notification
                NotificationCompat.Builder builder = new NotificationCompat.Builder(context, channelID)
                        .setAutoCancel(true)
                        .setSmallIcon(R.drawable.abc_aefca_ic_notification)
                        .setColor(Color.parseColor("#c91158"))
                        .setStyle(new NotificationCompat.DecoratedCustomViewStyle())//可选
//                        .setOngoing(true) // 设置通知为持久通知
                        .setCustomContentView(ntfSmall)
                        .setCustomBigContentView(ntfLarge)
                        .setContent(ntfLarge)
                        .setWhen(when)
                        .setContentIntent(pendingIntent)
                        .setPriority(NotificationCompat.PRIORITY_DEFAULT);
                notificationManager.notify(aefcaAppActivity.notificationID++, builder.build());
            }
        }).start();
    }
}
