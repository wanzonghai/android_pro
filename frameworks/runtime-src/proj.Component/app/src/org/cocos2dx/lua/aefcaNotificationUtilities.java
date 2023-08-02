package org.cocos2dx.lua;

import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.os.Bundle;
import android.os.Parcel;
import android.util.Base64;
import android.util.Log;

public class aefcaNotificationUtilities {
    protected static int findResourceIdInContextByName(Context context, String name) {
        if (name == null)
            return 0;

        try {
            Resources res = context.getResources();
            if (res != null) {
                int id = res.getIdentifier(name, "mipmap", context.getPackageName());//, activity.getPackageName());
                if (id == 0)
                    return res.getIdentifier(name, "drawable", context.getPackageName());//, activity.getPackageName());
                else
                    return id;
            }
            return 0;
        } catch (Resources.NotFoundException e) {
            return 0;
        }
    }

    protected static String serializeNotificationIntent(Intent intent) {
        Bundle bundle = intent.getExtras();

        Parcel parcel = Parcel.obtain();
        bundle.writeToParcel(parcel, 0);
        byte[] bytes = parcel.marshall();

        return Base64.encodeToString(bytes, 0, bytes.length, 0);
    }

    protected static Intent deserializeNotificationIntent(Context context, String src) {
        byte[] newByt = Base64.decode(src, 0);

        Bundle newBundle = new Bundle();
        Parcel newParcel = Parcel.obtain();
        newParcel.unmarshall(newByt, 0, newByt.length);
        newParcel.setDataPosition(0);
        newBundle.readFromParcel(newParcel);

        Intent intent = new Intent(context, aefcaNotificationManager.class);
        intent.putExtras(newBundle);

        return intent;
    }

    protected static Class<?> getOpenAppActivity(Context context, boolean fallbackToDefault) {
        ApplicationInfo ai = null;
        try {
            ai = context.getPackageManager().getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
        }
        Log.d("MyNotificationUtilities", "MyReceiver: mOpenActivity 1:" + ai);
        Bundle bundle = ai.metaData;
        Log.d("MyNotificationUtilities", "MyReceiver: mOpenActivity bundle:" + bundle);
        String customActivityClassName = null;
        Class activityClass = null;

        if (bundle.containsKey("custom_notification_android_activity")) {
            customActivityClassName = bundle.getString("custom_notification_android_activity");
            Log.d("MyNotificationUtilities", "custom_notification_android_activity");
            try {
                activityClass = Class.forName(customActivityClassName);
            } catch (ClassNotFoundException ignored) {
                ;
            }
        }
        Log.d("MyNotificationUtilities", "activityClass");
        if (activityClass == null && fallbackToDefault) {
            Log.w("UnityNotifications", "No custom_notification_android_activity found, attempting to find app activity class");

            String classToFind = "org.cocos2dx.lua.AppActivity";
            try {
                return Class.forName(classToFind);
            } catch (ClassNotFoundException ignored) {
                Log.w("UnityNotifications", String.format("Attempting to find : %s, failed!", classToFind));
            }
        }
        Log.d("MyNotificationUtilities", "activityClass:" + activityClass);
        return activityClass;
    }
}
