package game;

import android.app.Activity;
import android.app.Instrumentation;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.os.Bundle;
import android.os.IBinder;

import java.lang.reflect.Method;
import java.util.List;

public class ActivityInstrumentation extends Instrumentation {
    private Instrumentation mInstrumentation;
    private PackageManager mPackageManager;
    private String className;
    private Context m_context;

    public ActivityInstrumentation(Context context, Instrumentation mInstrumentation, PackageManager mPackageManager, String className) {
        this.m_context = context;
        this.mInstrumentation = mInstrumentation;
        this.mPackageManager = mPackageManager;
        this.className = className;
    }

    public ActivityResult execStartActivity(
            Context who, IBinder contextThread, IBinder token, Activity target,
            Intent intent, int requestCode, Bundle options) {
        List<ResolveInfo> infos = mPackageManager.queryIntentActivities(intent, PackageManager.MATCH_ALL);
        if (infos == null || infos.size() == 0) {
            intent.putExtra(Config.EXTRA_INTENT,intent.getComponent().getClassName());
            intent.setClassName(who,className);
        }
        try {
            Method execMethod = Instrumentation.class.getDeclaredMethod("execStartActivity",
                    Context.class, IBinder.class, IBinder.class, Activity.class, Intent.class,int.class, Bundle.class);
            return (ActivityResult) execMethod.invoke(mInstrumentation,who,contextThread,token,target,intent,requestCode,options);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public Activity newActivity(ClassLoader cl, String className, Intent intent) throws
            InstantiationException, IllegalAccessException, ClassNotFoundException {
        Activity activity  = mInstrumentation.newActivity(cl, className, intent);
        try {
//            intent.setExtrasClassLoader(m_context.getClassLoader());
            intent.setExtrasClassLoader(cl);
            if(null == ResourceManager.getLocalResources()){
                ResourceManager.init(m_context, Config.get_zip_file_path(m_context));
            }
            Reflector.QuietReflector.with(activity).field("mResources").set(ResourceManager.getLocalResources());
        }catch(Exception e){
            e.printStackTrace();
        }
        return activity;
    }
}
