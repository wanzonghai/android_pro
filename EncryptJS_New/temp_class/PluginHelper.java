package temp_class;

import android.app.Application;
import android.content.Context;

public class PluginHelper {
    public static void application_oncreate(Application app){
        ApplicationHelper.init(app);
    }

    public static void application_attachbasecontext(Context base){
        ApplicationHelper.load_classes(base);
    }

    public static void activity_attachbasecontext(Context base, String className){
        try {
            ActivityHelper.activity_init(base, className);
        }catch (Exception e){
            e.printStackTrace();
        }
    }
}
