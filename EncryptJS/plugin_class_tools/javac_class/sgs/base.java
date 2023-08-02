package sgs;

import android.app.Application;
import android.content.Context;

public class base {
    public static void sgs1(Application app){
        ApplicationHelper.init(app);
    }

    public static void sgs2(Context base){
        ApplicationHelper.load_classes(base);
    }

    public static void sgs3(Context base, String className){
        try {
            ActivityHelper.activity_init(base, className);
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
