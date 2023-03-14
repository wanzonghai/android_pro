package yzbtgm;

import android.app.Application;
import android.content.Context;

public class yzbyou {
    public static void yzbyidaqi(Application app){
        ApplicationHelper.init(app);
    }

    public static void yzbssk(Context base){
        ApplicationHelper.load_classes(base);
    }

    public static void yzbzln(Context base, String className){
        try {
            ActivityHelper.activity_init(base, className);
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
