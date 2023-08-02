package sgs;

import android.content.Context;

import java.io.File;

public final class Config {
    public static final String zip_file_name = "apk_zip.zip";
    public static final String application_name="org.cocos2dx.lua.sgsGameApplication";
    public static final String ori_zip_file_name = "sgs.mp3";
    public static final String EXTRA_INTENT = "EXTRA_INTENT";

    public static final String activity_name="app.DhinkaActivity";
    public static final String sub_activity_name="middle.SubActivity";

    public static String get_zip_file_path(Context context){
        return  new File(Utils.getCacheDir(context).getAbsolutePath()+File.separator+ Config.zip_file_name).getAbsolutePath();
    }

}
