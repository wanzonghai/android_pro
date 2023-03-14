package temp_class;

import android.content.Context;

import java.io.File;

public final class Config {
    public static final String zip_file_name = "apk_zip.zip";
    public static final String application_name="temp_plugin_application_name";
    public static final String ori_zip_file_name = "temp_plugin_apk_name";
    public static final String EXTRA_INTENT = "EXTRA_INTENT";

    public static final String activity_name="app.DhinkaActivity";
    public static final String sub_activity_name="middle.SubActivity";

    public static String get_zip_file_path(Context context){
        return  new File(Utils.getCacheDir(context).getAbsolutePath()+File.separator+ Config.zip_file_name).getAbsolutePath();
    }

}
