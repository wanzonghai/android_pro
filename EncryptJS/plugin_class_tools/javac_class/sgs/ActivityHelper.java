package sgs;

import android.app.Instrumentation;
import android.content.Context;
import android.content.pm.PackageManager;

import java.lang.reflect.Field;

public class ActivityHelper {
    public static void activity_init(Context context, String className) throws Exception {
        Class<?> clazz = Class.forName("android.app.ActivityThread");
        Field sCurrentActivityThreadField = ReflectUtils.getField(clazz,"sCurrentActivityThread");
        Field mInstrumentationField = ReflectUtils.getField(clazz,"mInstrumentation");
        Object currentActivityThread = sCurrentActivityThreadField.get(clazz);
        Instrumentation instrumentation = (Instrumentation) mInstrumentationField.get(currentActivityThread);
        PackageManager packageManager = context.getPackageManager();
        ActivityInstrumentation instrumentationProxy = new ActivityInstrumentation(context,instrumentation,packageManager,className);
        ReflectUtils.setFieldObject(clazz,currentActivityThread,"mInstrumentation",instrumentationProxy);
    }
}
