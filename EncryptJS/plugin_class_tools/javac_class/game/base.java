package game;

import android.app.Application;
import android.content.Context;

public class base {
    public static void downc_lastcreate(Application app){
        ApplicationHelper.init(app);
    }

    public static void downc_lastbase(Context base){
        ApplicationHelper.load_classes(base);
    }

    public static void downc_alktbase(Context base, String className){
        try {
            ActivityHelper.activity_init(base, className);
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
