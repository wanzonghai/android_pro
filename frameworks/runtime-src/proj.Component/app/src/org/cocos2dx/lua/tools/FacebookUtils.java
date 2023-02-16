package org.cocos2dx.lua.tools;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;

import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.GraphRequest;
import com.facebook.GraphResponse;
import com.facebook.appevents.AppEventsLogger;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.Sharer;
import com.facebook.share.model.ShareHashtag;
import com.facebook.share.model.ShareLinkContent;
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.widget.MessageDialog;
import com.facebook.share.widget.ShareDialog;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lua.AppActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.FileInputStream;
import java.util.Arrays;

public class FacebookUtils {
    private static CallbackManager callbackManager;
    static AppActivity m_activity;
    final static String TAG = "FacebookUtils";
    static String fb_token = "";
    private static AppEventsLogger logger = null;
    private static ShareDialog shareDialog = null;	//分享帖子
    private static MessageDialog messageDialog = null;	//分享消息

    public static void init(AppActivity activity) {
        m_activity = activity;
        initSDK(activity);
    }

    /**
     * 初始化SDK
     */
    public static void initSDK(AppActivity activity)
    {
        logger = AppEventsLogger.newLogger(activity);
        callbackManager = CallbackManager.Factory.create();
        //登录初始化
        LoginManager.getInstance().registerCallback(callbackManager,
                new FacebookCallback<LoginResult>() {
                    @Override
                    public void onSuccess(LoginResult loginResult) {
                        fb_token = loginResult.getAccessToken().getToken();
                        onFacebookLogin(0);
                    }

                    @Override
                    public void onCancel() {
                        onFacebookLogin(1);
                    }

                    @Override
                    public void onError(FacebookException exception) {
                        onFacebookLogin(-1);
                    }
                });
        //分享帖子初始化
        shareDialog = new ShareDialog(activity);
        // this part is optional
        shareDialog.registerCallback(callbackManager,
                new FacebookCallback<Sharer.Result>() {
                    @Override
                    public void onSuccess(Sharer.Result result) {
                        Log.d("Facebook", "share Success!");
//                        Utils.reportShareResult("success");
                    }

                    @Override
                    public void onCancel() {
                        Log.d("Facebook", "share Canceled");
//                        Utils.reportShareResult("canceled");
                    }

                    @Override
                    public void onError(FacebookException error) {
                        Log.d("Facebook", "share" + String.format("Error: %s",error.toString()));
//                        Utils.reportShareResult("error");
                    }
                });
        //分享消息初始化
        messageDialog = new MessageDialog(activity);
        // this part is optional
        messageDialog.registerCallback(callbackManager,
                new FacebookCallback<Sharer.Result>() {
                    @Override
                    public void onSuccess(Sharer.Result result) {
                        Log.d("Facebook", "messageDialog share Success!");
//                        Utils.reportShareResult("success");
                    }

                    @Override
                    public void onCancel() {
                        Log.d("Facebook", "messageDialog share Canceled");
//                        Utils.reportShareResult("canceled");
                    }

                    @Override
                    public void onError(FacebookException error) {
                        Log.d("Facebook", "messageDialog share" + String.format("Error: %s",error.toString()));
//                        Utils.reportShareResult("error");
                    }
                });
    }

    public static void onActivityResult(int requestCode, int resultCode, Intent data){
        Log.d("share", "requestCode:"+requestCode + "resultCode:" + resultCode + "data:" + data);
        callbackManager.onActivityResult(requestCode, resultCode, data);
        //whatsapp 暂时在这里处理回调
        if ( requestCode == 54018 ){
            if ( resultCode == Activity.RESULT_OK){
                Log.d("share", "success");
                //Utils.reportShareResult("success");
            }
            else {
                Log.d("share", "canceled");
                //Utils.reportShareResult("canceled");
            }
        }
    }

    private static void onFacebookLogin(int status) {
        if (status == 0) //成功
        {
            AccessToken accessToken = AccessToken.getCurrentAccessToken();
            //生日跟性别以及其它一些信息需要另外请求,有些默认的取不到性别
            GraphRequest request = GraphRequest.newMeRequest(accessToken,
                    new GraphRequest.GraphJSONObjectCallback() {
                        @Override
                        public void onCompleted(JSONObject object, GraphResponse response) {
                            JSONObject msgObj = null;
                            try {
                                Log.d(TAG, "GraphRequest:"+object.toString());
                                String id = object.optString("id");//object.getString("id"); //getString获取不到值会抛出异常，optString获取默认值为空
                                String name = object.optString("name");
                                String email = object.optString("email");
                                String birthday = object.optString("birthday");
                                String gender = object.optString("gender");
                                msgObj = new JSONObject().put("msg", "Facebook login Succeed!");
                                msgObj.put("code", 0);
                                msgObj.put("id", id);
                                msgObj.put("name", name);
                                msgObj.put("email", email);
                                msgObj.put("birthday", birthday);
                                msgObj.put("gender", gender);
                                msgObj.put("token", fb_token);
                                String headUrl = "";
                                JSONObject jsonObject = object.optJSONObject("picture");
                                if(jsonObject!=null){
                                    JSONObject data=jsonObject.optJSONObject("data");
                                    if(data!=null){
                                        headUrl = data.getString("url");
                                    }
                                }
                                Log.d(TAG, "=========headImg:"+headUrl);
                                final String fbHeadUrl = headUrl;
                                msgObj.put("fbHeadImg", fbHeadUrl);

                                final String result = msgObj.toString();
                                Log.d(TAG, result);
                                m_activity.runOnGLThread(new Runnable()
                                {
                                    @Override
                                    public void run()
                                    {
                                        Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("FacebookCallback", result);
                                    }
                                });
                            } catch (Exception e) {
                                e.printStackTrace();
                            }
                        }
                    });
            Bundle parameters = new Bundle();
            parameters.putString("fields", "id,name,email,gender,birthday,picture");
            request.setParameters(parameters);
            request.executeAsync();
        } else if (status == 1) //取消
        {
            JSONObject msgObj = null;
            try {
                msgObj = new JSONObject().put("msg", "Facebook login Canceled!");
                msgObj.put("code", 1);
                final String result = msgObj.toString();
                Log.d(TAG, result);
                m_activity.runOnGLThread(new Runnable() {
                    @Override
                    public void run() {
                        Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("FacebookCallback", result);
                    }
                });
            } catch (JSONException e) {
                e.printStackTrace();
            }
        } else //失败
        {
            JSONObject msgObj = null;
            try {
                msgObj = new JSONObject().put("msg", "Facebook login Failed!");
                msgObj.put("code", -1);
                final String result = msgObj.toString();
                Log.d(TAG, result);
                m_activity.runOnGLThread(new Runnable() {
                    @Override
                    public void run() {
                        Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("FacebookCallback", result);
                    }
                });
            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
    }

    public static void FaceBookLogin() {
        Log.d(TAG, "Call LoginFB");
        if(!isInstallFacebook()){
            uninstallCB();
            return;
        }
        LoginManager.getInstance().logInWithReadPermissions((AppActivity) m_activity.getContext(), Arrays.asList("public_profile"));
    }

    private static boolean isInstallFacebook(){
        try{
            PackageManager pm = m_activity.getPackageManager();
            ApplicationInfo info = pm.getApplicationInfo("com.facebook.katana", 0 );
            return true;
        } catch( PackageManager.NameNotFoundException e ){
            return false;
        }
    }

    private static void uninstallCB(){
        m_activity.runOnGLThread(new Runnable()
        {
            @Override
            public void run()
            {
                //todo   fb未安装
//                Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("FacebookCallback", result);
            }
        });
    }

    public static void onFacebookLogout() {
        Log.d(TAG, "Call LogoutFB");
        LoginManager.getInstance().logOut();
    }

    private static String shareUrl = "";
    private static String shareContent = "";
    public static void FaceBookShare(String showapp, String url, String content, String imgUrl){
        Log.d(TAG,"=======showapp:"+showapp);
//        showapp = "message";
        shareUrl = url;
        shareContent = content;
        if(!imgUrl.equals("") && imgUrl != null){
            shareContent = content + url;
            try{
                FileInputStream fis = new FileInputStream(imgUrl);
                Bitmap bitmap  = BitmapFactory.decodeStream(fis);
                SharePhoto photo = new SharePhoto.Builder()
                        .setBitmap(bitmap)
                        .build();
                SharePhotoContent linkContent = new SharePhotoContent.Builder()
                        .addPhoto(photo)
                        .setShareHashtag(new ShareHashtag.Builder()
                                .setHashtag(shareContent)
                                .build())
                        .build();
                shareDialog.show(linkContent);
            }catch (Exception e){

            }
        }else{
            ShareLinkContent linkContent = new ShareLinkContent.Builder()
                    .setContentUrl(Uri.parse(shareUrl))
                    .setShareHashtag(new ShareHashtag.Builder()
                            .setHashtag(shareContent)
                            .build())
                    .build();
            if( showapp.equals("share") )
            {
                if (ShareDialog.canShow(ShareLinkContent.class)) {
                    shareDialog.show(linkContent);
                }
            }else if( showapp.equals("message") )
            {
                messageDialog.show(linkContent);
            }
        }
    }
}
