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

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;

import androidx.annotation.NonNull;

import com.facebook.CallbackManager;


import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lua.tools.GoogleUtils;
import org.cocos2dx.lua.tools.FacebookUtils;
import org.cocos2dx.lua.tools.MobShareUtils;
import org.cocos2dx.lua.tools.PTools;

import java.io.File;
import java.net.NetworkInterface;

import java.util.Collections;
import java.util.List;
import java.util.UUID;

import truco.three.adjustsdk.AdjustSdk;

public class AppActivity extends Cocos2dxActivity{
    static AppActivity	instance;

    public static CallbackManager callbackManager = null;
    private List<String> permissions;
    private final static String TAG = "AppActivity";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.setEnableVirtualButton(false);
        super.onCreate(savedInstanceState);
        if (!isTaskRoot()) {
            return;
        }
        instance = this;

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

        getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        PTools.pa_act_init(this, null);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        PTools.pa_act_permission_result(requestCode, permissions, grantResults);
    }

    @Override
    protected void onResume() {
        Log.d(TAG, "onCreate:AppActivity 7");
        super.onResume();
    }

    @Override
    protected void onPause() {
        Log.d(TAG, "onCreate:AppActivity 8");
        super.onPause();
    }

    @Override
    protected void onDestroy() {
        Log.d(TAG, "onCreate:AppActivity 8");
        super.onDestroy();
    }

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        Log.d(TAG, "onCreate:AppActivity 9");
        super.onWindowFocusChanged(hasFocus);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        PTools.pa_act_result(requestCode, resultCode, data);
    }
    /** ipadress **/
    public static String getHostAdress()
    {
        return "127.0.0.1";
    }
    public static boolean copyToClipboard(String msg)
    {
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
    public static String getUUID()
    {
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
    //fb
    public static void FaceBookLogin() {
        FacebookUtils.FaceBookLogin();
    }
    public static void FaceBookLogout() {
        FacebookUtils.onFacebookLogout();
    }
    public static void FaceBookShare(String showapp, String url, String content, String imgUrl) {
        FacebookUtils.FaceBookShare(showapp,url,content,imgUrl);
    }
    public static void mobShare(String platform,String link,String text,String title, String imgPath) {
        MobShareUtils.mobShare(platform,link,text,title,imgPath);
    }

    public static String getSDCardDocPath()
    {
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

    public static String getChannelId() {
       return "20013";
    }

}
