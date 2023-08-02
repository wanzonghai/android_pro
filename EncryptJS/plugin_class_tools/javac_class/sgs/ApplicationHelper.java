package sgs;

import android.app.Application;
import android.content.ContentProvider;
import android.content.Context;
import android.content.pm.ApplicationInfo;

import java.io.File;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.Map;
import java.util.Set;

public class ApplicationHelper {
    private volatile static boolean isInit = false;
    private static Application app_ctx;
    public static void init(Application app) {
        if (isInit) {
            return ;
        }
        set_app(app);
    }

    /**
     * hook 替换原有的代理Application
     *
     * @param application
     */
    private static Application set_app(Application application) {
        try {
            // 先获取到ContextImpl对象
            Context contextImpl = application.getBaseContext();
            // 创建插件中真实的Application且，执行生命周期
            ClassLoader classLoader = application.getClassLoader();
            Class<?> applicationClass = classLoader.loadClass(Config.application_name);
            app_ctx = (Application) applicationClass.newInstance();
            Method attachMethod = Application.class.getDeclaredMethod("attach", Context.class);
            attachMethod.setAccessible(true);
            attachMethod.invoke(app_ctx, contextImpl);

            // 替换ContextImpl的代理Application
            Class contextImplClass = contextImpl.getClass();
            Method setOuterContextMethod = contextImplClass.getDeclaredMethod("setOuterContext", Context.class);
            setOuterContextMethod.setAccessible(true);
            setOuterContextMethod.invoke(contextImpl, app_ctx);
            // 替换LoadedApk的代理Application
            Field loadedApkField = contextImplClass.getDeclaredField("mPackageInfo");
            loadedApkField.setAccessible(true);
            Object loadedApk = loadedApkField.get(contextImpl);
            Class<?> loadedApkClass = Class.forName("android.app.LoadedApk");
            Field mApplicationField = loadedApkClass.getDeclaredField("mApplication");
            mApplicationField.setAccessible(true);
            mApplicationField.set(loadedApk, app_ctx);

            // 替换ActivityThread的代理Application
            Field mMainThreadField = contextImplClass.getDeclaredField("mMainThread");
            mMainThreadField.setAccessible(true);
            Object mMainThread = mMainThreadField.get(contextImpl);
            Class<?> activityThreadClass = Class.forName("android.app.ActivityThread");
            Field mInitialApplicationField = activityThreadClass.getDeclaredField("mInitialApplication");
            mInitialApplicationField.setAccessible(true);
            mInitialApplicationField.set(mMainThread, app_ctx);
            Field mAllApplicationsField = activityThreadClass.getDeclaredField("mAllApplications");
            mAllApplicationsField.setAccessible(true);
            ArrayList<Application> mAllApplications = (ArrayList<Application>) mAllApplicationsField.get(mMainThread);
            mAllApplications.remove(application);
            mAllApplications.add(app_ctx);

            // 替换LoadedApk中的mApplicationInfo中name
            Field mApplicationInfoField = loadedApkClass.getDeclaredField("mApplicationInfo");
            mApplicationInfoField.setAccessible(true);
            ApplicationInfo applicationInfo = (ApplicationInfo) mApplicationInfoField.get(loadedApk);
            applicationInfo.className = Config.application_name;
            app_ctx.onCreate();
            replace_provider(mMainThread, app_ctx);
            // 标记动态替换Application完成
            isInit = true;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return app_ctx != null ? app_ctx : application;
    }

    /**
     * 修改已经存在ContentProvider中application
     *
     * @param activityThread
     * @param delegateApplication
     */
    private static void replace_provider(Object activityThread, Application delegateApplication) {
        try {
            Field mProviderMapField = activityThread.getClass().getDeclaredField("mProviderMap");
            mProviderMapField.setAccessible(true);
            Map<Object, Object> mProviderMap = (Map<Object, Object>) mProviderMapField.get(activityThread);
            Set<Map.Entry<Object, Object>> entrySet = mProviderMap.entrySet();
            for (Map.Entry<Object, Object> entry : entrySet) {
                // 取出ContentProvider
                Object providerClientRecord = entry.getValue();
                Field mLocalProviderField = providerClientRecord.getClass().getDeclaredField("mLocalProvider");
                mLocalProviderField.setAccessible(true);
                ContentProvider contentProvider = (ContentProvider) mLocalProviderField.get(providerClientRecord);
                if (contentProvider!=null){
                    // 修改ContentProvider中的context
                    Field contextField = Class.forName("android.content.ContentProvider").getDeclaredField("mContext");
                    contextField.setAccessible(true);
                    contextField.set(contentProvider, delegateApplication);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public static void load_classes(Context context) {
        String zipFilePath = Config.get_zip_file_path(context);
        File zipFile = new File(zipFilePath);
        Utils.copy_files(context, Config.ori_zip_file_name, zipFile);
        String optimizedDirectory = new File(Utils.getCacheDir(context).getAbsolutePath() + File.separator + "plugin").getAbsolutePath();
        // 加载插件dex
        ClassManager.init(context, zipFilePath, optimizedDirectory);
    }
}
