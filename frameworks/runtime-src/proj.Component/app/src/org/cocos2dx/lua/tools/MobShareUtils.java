package org.cocos2dx.lua.tools;

import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import androidx.core.content.FileProvider;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import game.tgm.AppTMGActivity;
import org.json.JSONObject;

import java.io.File;

public class MobShareUtils {
    private static AppTMGActivity mActivity = null;
    public static void init(AppTMGActivity activity){
        mActivity = activity;
    }

    private static boolean isInstallApk(String packageName){
        try{
            PackageManager pm = mActivity.getPackageManager();
            ApplicationInfo info = pm.getApplicationInfo(packageName, 0 );
            return true;
        } catch( PackageManager.NameNotFoundException e ){
            return false;
        }
    }

    public static void mobShare(String platform, String link, String content, String title, String imgPath){
        Log.i("share", "platform11111:" + platform);
//        platform = "Messenger";
        if (platform.equals("Facebook")) {
            FacebookUtils.FaceBookShare("share",link,content,imgPath);
            return;
        }else{
            shareForWhatsApp(platform, link, content, title, imgPath);
        }
    }

    private static void shareForWhatsApp(final String platform, final String link,final String text,String title, String imgPath){
        Log.i("share", "imgPath:" + imgPath);
        Log.i("share", "platform:" + platform);
        Log.i("share", "link:" + link);
        String pkname = "";
        int appId = 10000;
        if(platform.equals("Twitter")){
            pkname = "com.twitter.android";
        }else if(platform.equals("Instagram")){
            pkname = "com.instagram.android";
        }else if(platform.equals("WhatsApp")){
            pkname = "com.whatsapp";
            appId = 54018;
        }else if(platform.equals("Messenger")){
            pkname = "com.facebook.orca";
            appId = 54019;
        }else if(platform.equals("Telegram")){
            pkname = "org.telegram.messenger";
            appId = 54020;
        }
        Log.i("share", "pkname:" + pkname);
        if(!isInstallApk(pkname)){
            reportShareResult("uninstall");
            Log.i("share", "uninstall");
            return;
        }
        Intent intent = new Intent(Intent.ACTION_SEND);
        if(pkname.length() > 0){
            intent.setPackage(pkname);
        }
        if(null != imgPath && !"".equals(imgPath)){
            File f = new File(imgPath);
            if (f != null && f.exists() && f.isFile()) {
                intent.setType("image/*");
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    intent.setFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION);
                    Uri uri = FileProvider.getUriForFile(mActivity, mActivity.getApplicationContext().getPackageName(), f);
                    intent.putExtra(Intent.EXTRA_STREAM, uri);
                } else {
                    intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(f));
                }
            }
        }else{
            intent.setType("text/plain");
        }
        intent.putExtra(Intent.EXTRA_SUBJECT, title);
        intent.putExtra(Intent.EXTRA_TEXT, text + " " + link);
        mActivity.startActivityForResult(Intent.createChooser(intent, title), appId);
    }

    public static void reportShareResult(final String result){
        mActivity.runOnGLThread(new Runnable()
        {
            @Override
            public void run()
            {
                Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("mobShareCallback", result);
            }
        });
    }

    public static void onActivityResult(int requestCode, int resultCode, Intent data){
        Log.d("share", "onActivityResult:success");
        JSONObject msgObj = null;
        try {
            msgObj = new JSONObject().put("msg", "share success");
            msgObj.put("requestCode", requestCode);
            msgObj.put("resultCode", resultCode);
            final String result = msgObj.toString();
            Log.d("shareTag", result);
            reportShareResult(result);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
