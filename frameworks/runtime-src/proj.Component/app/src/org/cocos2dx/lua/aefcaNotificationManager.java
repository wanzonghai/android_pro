package org.cocos2dx.lua;

import android.app.Activity;
import android.app.AlarmManager;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;

//import androidx.core.app.NotificationCompat;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.BadParcelableException;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import static android.app.Notification.VISIBILITY_PUBLIC;

import java.io.InputStream;
import java.lang.reflect.Method;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import aefca.fts.tytnss.R;


public class aefcaNotificationManager extends BroadcastReceiver {
    public static String TAG = "MyNotificationManager";
    protected static NotificationCallback mNotificationCallback;
    protected static aefcaNotificationManager mUnityNotificationManager;

    public static Context mContext = null;
    protected Activity mActivity = null;
    protected static Class mOpenActivity = null;
    protected static boolean mRescheduleOnRestart = false;
    protected static Method mCanScheduleExactAlarms;

    protected static final String NOTIFICATION_CHANNELS_SHARED_PREFS = "UNITY_NOTIFICATIONS";
    protected static final String NOTIFICATION_CHANNELS_SHARED_PREFS_KEY = "ChannelIDs";
    protected static final String NOTIFICATION_IDS_SHARED_PREFS = "UNITY_STORED_NOTIFICATION_IDS";
    protected static final String NOTIFICATION_IDS_SHARED_PREFS_KEY = "UNITY_NOTIFICATION_IDS";
    

    public aefcaNotificationManager() {
        super();
    }

    public aefcaNotificationManager(Context context, Activity activity) {
        super();
        Log.d(TAG, "Constructor: MyNotificationManager(Context context, Activity activity)");
        mContext = context;
        mActivity = activity;

        try {
            ActivityInfo ai = activity.getPackageManager().getActivityInfo(activity.getComponentName(), PackageManager.GET_META_DATA);
            Bundle bundle = ai.metaData;
            Log.d(TAG, "Constructor: bundle:"+bundle);
            Boolean rescheduleOnRestart = bundle.getBoolean("reschedule_notifications_on_restart");
            Log.d(TAG, "Constructor: rescheduleOnRestart:"+rescheduleOnRestart);
            rescheduleOnRestart =true;
            if (rescheduleOnRestart) {
                ComponentName receiver = new ComponentName(activity, aefcaNotificationRestartOnBootReceiver.class);
                PackageManager pm = activity.getPackageManager();

                pm.setComponentEnabledSetting(receiver,
                        PackageManager.COMPONENT_ENABLED_STATE_ENABLED,
                        PackageManager.DONT_KILL_APP);
            }

            this.mRescheduleOnRestart = rescheduleOnRestart;
            Log.d(TAG, "Constructor: mOpenActivity 1:"+mOpenActivity);
            mOpenActivity = aefcaNotificationUtilities.getOpenAppActivity(context, false);
            if (mOpenActivity == null)
                mOpenActivity = activity.getClass();
            Log.d(TAG, "Constructor: mOpenActivity 2:"+mOpenActivity);
        } catch (PackageManager.NameNotFoundException e) {
            Log.e(TAG, "Failed to load meta-data, NameNotFound: " + e.getMessage());
        } catch (NullPointerException e) {
            Log.e(TAG, "Failed to load meta-data, NullPointer: " + e.getMessage());
        }
    }

    public static aefcaNotificationManager getNotificationManagerImpl(Context context) {
        return getNotificationManagerImpl(context, (Activity) context);
    }

    // Called from managed code.
    public static aefcaNotificationManager getNotificationManagerImpl(Context context, Activity activity) {
        Log.d(TAG, "getNotificationManagerImpl: 1 mUnityNotificationManager:" + mUnityNotificationManager);
        if (mUnityNotificationManager != null)
            return mUnityNotificationManager;
        Log.d(TAG, "getNotificationManagerImpl: 2");
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Log.d(TAG, "getNotificationManagerImpl: 3");
            mUnityNotificationManager = new aefcaNotificationManagerOreo(context, activity);
        } else {
            mUnityNotificationManager = new aefcaNotificationManager(context, activity);
        }
        Log.d(TAG, "getNotificationManagerImpl: 4");
        return mUnityNotificationManager;
    }

    public static NotificationManager getNotificationManager() {
        return getNotificationManager(mContext);
    }

    // Get system notification service.
    public static NotificationManager getNotificationManager(Context context) {
        return (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
    }

    // Called from managed code.
    public void setNotificationCallback(NotificationCallback notificationCallback) {
        aefcaNotificationManager.mNotificationCallback = notificationCallback;
    }
	
    // Register a new notification channel.
    // This function will only be called for devices which are low than Android O.
    public void registerNotificationChannel(
            String id,
            String name,
            int importance,
            String description,
            boolean enableLights,
            boolean enableVibration,
            boolean canBypassDnd,
            boolean canShowBadge,
            long[] vibrationPattern,
            int lockscreenVisibility) {
        SharedPreferences prefs = mContext.getSharedPreferences(NOTIFICATION_CHANNELS_SHARED_PREFS, Context.MODE_PRIVATE);
        Set<String> channelIds = new HashSet<String>(prefs.getStringSet(NOTIFICATION_CHANNELS_SHARED_PREFS_KEY, new HashSet<String>()));
        channelIds.add(id); // TODO: what if users create the channel again with the same id?

        // Add to notification channel ids SharedPreferences.
        SharedPreferences.Editor editor = prefs.edit().clear();
        editor.putStringSet("ChannelIDs", channelIds);
        editor.apply();

        // Store the channel into a SharedPreferences.
        SharedPreferences channelPrefs = mContext.getSharedPreferences(getSharedPrefsNameByChannelId(id), Context.MODE_PRIVATE);
        editor = channelPrefs.edit();

        editor.putString("title", name); // Sadly I can't change the "title" here to "name" due to backward compatibility.
        editor.putInt("importance", importance);
        editor.putString("description", description);
        editor.putBoolean("enableLights", enableLights);
        editor.putBoolean("enableVibration", enableVibration);
        editor.putBoolean("canBypassDnd", canBypassDnd);
        editor.putBoolean("canShowBadge", canShowBadge);
        editor.putString("vibrationPattern", Arrays.toString(vibrationPattern));
        editor.putInt("lockscreenVisibility", lockscreenVisibility);

        editor.apply();
    }

    protected static String getSharedPrefsNameByChannelId(String id)
    {
        return String.format("unity_notification_channel_%s", id);
    }
    
    // Get a notification channel by id.
    // This function will only be called for devices which are low than Android O.
    protected static NotificationChannelWrapper getNotificationChannel(Context context, String id) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            return aefcaNotificationManagerOreo.getOreoNotificationChannel(context, id);
        }

        SharedPreferences prefs = context.getSharedPreferences(getSharedPrefsNameByChannelId(id), Context.MODE_PRIVATE);
        NotificationChannelWrapper channel = new NotificationChannelWrapper();

        channel.id = id;
        channel.name = prefs.getString("title", "undefined");
        channel.importance = prefs.getInt("importance", NotificationManager.IMPORTANCE_DEFAULT);
        channel.description = prefs.getString("description", "undefined");
        channel.enableLights = prefs.getBoolean("enableLights", false);
        channel.enableVibration = prefs.getBoolean("enableVibration", false);
        channel.canBypassDnd = prefs.getBoolean("canBypassDnd", false);
        channel.canShowBadge = prefs.getBoolean("canShowBadge", false);
        channel.lockscreenVisibility = prefs.getInt("lockscreenVisibility", VISIBILITY_PUBLIC);
        String[] vibrationPatternStr = prefs.getString("vibrationPattern", "[]").split(",");

        long[] vibrationPattern = new long[vibrationPatternStr.length];

        if (vibrationPattern.length > 1) {
            for (int i = 0; i < vibrationPatternStr.length; i++) {
                try {
                    vibrationPattern[i] = Long.parseLong(vibrationPatternStr[i]);
                } catch (NumberFormatException e) {
                    vibrationPattern[i] = 1;
                }
            }
        }

        channel.vibrationPattern = vibrationPattern.length > 1 ? vibrationPattern : null;
        return channel;
    }

    // Get a notification channel by id.
    // This function will only be called for devices which are low than Android O.
    protected NotificationChannelWrapper getNotificationChannel(String id) {
        return aefcaNotificationManager.getNotificationChannel(mContext, id);
    }

    

    // Delete a notification channel by id.
    // This function will only be called for devices which are low than Android O.
    public void deleteNotificationChannel(String id) {
        SharedPreferences prefs = mContext.getSharedPreferences(NOTIFICATION_CHANNELS_SHARED_PREFS, Context.MODE_PRIVATE);
        Set<String> channelIds = new HashSet<String>(prefs.getStringSet(NOTIFICATION_CHANNELS_SHARED_PREFS_KEY, new HashSet<String>()));

        if (!channelIds.contains(id))
            return;

        // Remove from the notification channel ids SharedPreferences.
        channelIds.remove(id);
        SharedPreferences.Editor editor = prefs.edit().clear();
        editor.putStringSet(NOTIFICATION_CHANNELS_SHARED_PREFS_KEY, channelIds);
        editor.apply();

        // Delete the notification channel SharedPreferences.
        SharedPreferences channelPrefs = mContext.getSharedPreferences(getSharedPrefsNameByChannelId(id), Context.MODE_PRIVATE);
        channelPrefs.edit().clear().apply();
    }

	// Get all notification channels.
    // This function will only be called for devices which are low than Android O.
    public Object[] getNotificationChannels() {
        SharedPreferences prefs = mContext.getSharedPreferences(NOTIFICATION_CHANNELS_SHARED_PREFS, Context.MODE_PRIVATE);
        Set<String> channelIdsSet = prefs.getStringSet(NOTIFICATION_CHANNELS_SHARED_PREFS_KEY, new HashSet<String>());

        ArrayList<NotificationChannelWrapper> channels = new ArrayList<>();

        for (String k : channelIdsSet) {
            channels.add(getNotificationChannel(k));
        }
        return channels.toArray();
    }
    // This is called from Unity managed code to call AlarmManager to set a broadcast intent for sending a notification.
    public static void scheduleNotificationIntent(Intent data_intent_source) {
        // TODO: why we serialize/deserialize again?
        String temp = aefcaNotificationUtilities.serializeNotificationIntent(data_intent_source);
        Intent data_intent = aefcaNotificationUtilities.deserializeNotificationIntent(mContext, temp);

        int id = data_intent.getIntExtra("id", 0);

        Intent openAppIntent = aefcaNotificationManager.buildOpenAppIntent(data_intent, mContext, mOpenActivity);
        PendingIntent pendingIntent = getActivityPendingIntent(mContext, id, openAppIntent, 0);
        Intent intent = buildNotificationIntent(mContext, data_intent, pendingIntent);

        if (intent != null) {
            if (mRescheduleOnRestart) {
                aefcaNotificationManager.saveNotificationIntent(mContext, data_intent);
            }

            PendingIntent broadcast = getBroadcastPendingIntent(mContext, id, intent, PendingIntent.FLAG_UPDATE_CURRENT);
            aefcaNotificationManager.scheduleNotificationIntentAlarm(mContext, intent, broadcast);
        }
    }

    // Build an Intent to open the given activity with the data from input Intent.
    protected static Intent buildOpenAppIntent(Intent data_intent, Context context, Class className) {
        Intent openAppIntent = new Intent(context, className);
        openAppIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        openAppIntent.putExtras(data_intent);

        return openAppIntent;
    }

    // Build a notification Intent to store the PendingIntent.
    protected static Intent buildNotificationIntent(Context context, Intent intent, PendingIntent pendingIntent) {
        Intent data_intent = (Intent) intent.clone();
        data_intent.putExtra("tapIntent", pendingIntent);

        SharedPreferences prefs = context.getSharedPreferences(NOTIFICATION_IDS_SHARED_PREFS, Context.MODE_PRIVATE);
        Set<String> ids = new HashSet<String>(prefs.getStringSet(NOTIFICATION_IDS_SHARED_PREFS_KEY, new HashSet<String>()));

        Set<String> validNotificationIds = new HashSet<String>();
        for (String id : ids) {
            // Get the given broadcast PendingIntent by id as request code.
            // FLAG_NO_CREATE is set to return null if the described PendingIntent doesn't exist.
            PendingIntent broadcast = getBroadcastPendingIntent(context, Integer.valueOf(id), intent, PendingIntent.FLAG_NO_CREATE);

            if (broadcast != null) {
                validNotificationIds.add(id);
            }
        }

        if (android.os.Build.MANUFACTURER.equals("samsung") && validNotificationIds.size() >= 499) {
            // There seems to be a limit of 500 concurrently scheduled alarms on Samsung devices.
            // Attempting to schedule more than that might cause the app to crash.
            Log.w("UnityNotifications", "Attempting to schedule more than 500 notifications. There is a limit of 500 concurrently scheduled Alarms on Samsung devices" +
                    " either wait for the currently scheduled ones to be triggered or cancel them if you wish to schedule additional notifications.");
            data_intent = null;
        } else {
            int id = data_intent.getIntExtra("id", 0);
            validNotificationIds.add(Integer.toString(id));
            data_intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        }

        SharedPreferences.Editor editor = prefs.edit().clear();
        editor.putStringSet(NOTIFICATION_IDS_SHARED_PREFS_KEY, validNotificationIds);
        editor.apply();

        return data_intent;
    }

    public static PendingIntent getActivityPendingIntent(Context context, int id, Intent intent, int flags) {
        if (Build.VERSION.SDK_INT >= 23)
            return PendingIntent.getActivity(context, id, intent, flags | PendingIntent.FLAG_IMMUTABLE);
        else
            return PendingIntent.getActivity(context, id, intent, flags);
    }

    public static PendingIntent getBroadcastPendingIntent(Context context, int id, Intent intent, int flags) {
        if (Build.VERSION.SDK_INT >= 23)
            return PendingIntent.getBroadcast(context, id, intent, flags | PendingIntent.FLAG_IMMUTABLE);
        else
            return PendingIntent.getBroadcast(context, id, intent, flags);
    }

    // Save the notification intent to SharedPreferences if reschedule_on_restart is true,
    // which will be consumed by UnityNotificationRestartOnBootReceiver for device reboot.
    protected static void saveNotificationIntent(Context context, Intent intent) {
        String notification_id = Integer.toString(intent.getIntExtra("id", 0));
        SharedPreferences prefs = context.getSharedPreferences(getSharedPrefsNameByNotificationId(notification_id), Context.MODE_PRIVATE);

        SharedPreferences.Editor editor = prefs.edit().clear();
        String data = aefcaNotificationUtilities.serializeNotificationIntent(intent);
        editor.putString("data", data);
        editor.apply();

        // Add the id to notification ids SharedPreferences.
        SharedPreferences idsPrefs = context.getSharedPreferences(NOTIFICATION_IDS_SHARED_PREFS, Context.MODE_PRIVATE);
        Set<String> ids = new HashSet<String>(idsPrefs.getStringSet(NOTIFICATION_IDS_SHARED_PREFS_KEY, new HashSet<String>()));
        ids.add(notification_id);

        SharedPreferences.Editor idsEditor = idsPrefs.edit().clear();
        idsEditor.putStringSet(NOTIFICATION_IDS_SHARED_PREFS_KEY, ids);
        idsEditor.apply();

        // TODO: why we load after saving?
        aefcaNotificationManager.loadNotificationIntents(context);
    }

    protected static String getSharedPrefsNameByNotificationId(String id)
    {
        return String.format("u_notification_data_%s", id);
    }

    // Load all the notification intents from SharedPreferences.
    protected static List<Intent> loadNotificationIntents(Context context) {
        SharedPreferences idsPrefs = context.getSharedPreferences(NOTIFICATION_IDS_SHARED_PREFS, Context.MODE_PRIVATE);
        Set<String> ids = new HashSet<String>(idsPrefs.getStringSet(NOTIFICATION_IDS_SHARED_PREFS_KEY, new HashSet<String>()));

        List<Intent> intent_data_list = new ArrayList<Intent>();
        Set<String> idsMarkedForRemoval = new HashSet<String>();

        for (String id : ids) {
            SharedPreferences prefs = context.getSharedPreferences(getSharedPrefsNameByNotificationId(id), Context.MODE_PRIVATE);
            String serializedIntentData = prefs.getString("data", "");

            if (serializedIntentData.length() > 1) {
                Intent intent = aefcaNotificationUtilities.deserializeNotificationIntent(context, serializedIntentData);
                intent_data_list.add(intent);
            } else {
                idsMarkedForRemoval.add(id);
            }
        }

        for (String id : idsMarkedForRemoval) {
            aefcaNotificationManager.deleteExpiredNotificationIntent(context, id);
        }

        return intent_data_list;
    }

    private static boolean canScheduleExactAlarms(AlarmManager alarmManager) {
        // exact scheduling supported since Android 6
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M)
            return false;
        if (Build.VERSION.SDK_INT < 31)
            return true;

        try {
            if (mCanScheduleExactAlarms == null)
                mCanScheduleExactAlarms = AlarmManager.class.getMethod("canScheduleExactAlarms");
            return (boolean)mCanScheduleExactAlarms.invoke(alarmManager);
        } catch (NoSuchMethodException ex) {
            Log.e("UnityNotifications", "No AlarmManager.canScheduleExactAlarms() on Android 31+ device, should not happen", ex);
            return false;
        } catch (Exception ex) {
            Log.e("UnityNotifications", "AlarmManager.canScheduleExactAlarms() threw", ex);
            return false;
        }
    }

    // Call AlarmManager to set the broadcast intent with fire time and interval.
    protected static void scheduleNotificationIntentAlarm(Context context, Intent intent, PendingIntent broadcast) {
        long repeatInterval = intent.getLongExtra("repeatInterval", 0L);
        long fireTime = intent.getLongExtra("fireTime", 0L);

        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);

        if (repeatInterval <= 0) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && canScheduleExactAlarms(alarmManager)) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, fireTime, broadcast);
            } else {
                alarmManager.set(AlarmManager.RTC_WAKEUP, fireTime, broadcast);
            }
        } else {
            alarmManager.setInexactRepeating(AlarmManager.RTC_WAKEUP, fireTime, repeatInterval, broadcast);
        }
    }

































    

    

    

    

    

    

    

    // Cancel a pending notification by id.
    public void cancelPendingNotificationIntent(int id) {
        aefcaNotificationManager.cancelPendingNotificationIntent(mContext, id);
        if (this.mRescheduleOnRestart) {
            aefcaNotificationManager.deleteExpiredNotificationIntent(mContext, Integer.toString(id));
        }
    }

    // Cancel a pending notification by id.
    protected static void cancelPendingNotificationIntent(Context context, int id) {
        Intent intent = new Intent(context, aefcaNotificationManager.class);
        PendingIntent broadcast = getBroadcastPendingIntent(context, id, intent, PendingIntent.FLAG_NO_CREATE);

        if (broadcast != null) {
            if (context != null) {
                AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
                alarmManager.cancel(broadcast);
            }
            broadcast.cancel();
        }

        SharedPreferences prefs = context.getSharedPreferences(NOTIFICATION_IDS_SHARED_PREFS, Context.MODE_PRIVATE);
        Set<String> ids = new HashSet<String>(prefs.getStringSet(NOTIFICATION_IDS_SHARED_PREFS_KEY, new HashSet<String>()));

        String idStr = Integer.toString(id);
        if (ids.contains(idStr)) {
            ids.remove(Integer.toString(id));

            SharedPreferences.Editor editor = prefs.edit().clear();
            editor.putStringSet(NOTIFICATION_IDS_SHARED_PREFS_KEY, ids);
            editor.apply();
        }
    }

    // Delete the notification intent from SharedPreferences by id.
    protected static void deleteExpiredNotificationIntent(Context context, String id) {
        SharedPreferences idsPrefs = context.getSharedPreferences(NOTIFICATION_IDS_SHARED_PREFS, Context.MODE_PRIVATE);
        Set<String> ids = new HashSet<String>(idsPrefs.getStringSet(NOTIFICATION_IDS_SHARED_PREFS_KEY, new HashSet<String>()));

        cancelPendingNotificationIntent(context, Integer.valueOf(id));

        ids.remove(id);
        SharedPreferences.Editor editor = idsPrefs.edit();
        editor.putStringSet(NOTIFICATION_IDS_SHARED_PREFS_KEY, ids);
        editor.apply();

        SharedPreferences notificationPrefs = context.getSharedPreferences(getSharedPrefsNameByNotificationId(id), Context.MODE_PRIVATE);
        notificationPrefs.edit().clear().apply();
    }

    
    

    


    

    

    @Override
    public void onReceive(Context context, Intent intent) {
        String pAction = intent.getAction();
        Log.d("MyNotificationManager", "onReceive() Action = "+pAction);
        try {

            if (!intent.hasExtra("channelID") || !intent.hasExtra("smallIconStr")) {
                Log.d("MyNotificationManager", "onReceive() no match Extra params");
                return;
            }

            Log.d("MyNotificationManager", "onReceive() Call sendNotification");
            aefcaNotificationManager.sendNotification(context, intent);
        } catch (BadParcelableException e) {
            Log.w("MyNotificationManager", e.toString());
        }

        // if (intent.getAction().equals(MainActivity.ACTION)) {  //my custom intent
        //     //---get the notification ID for the notification;
        //     // passed in by the MainActivity---
        //     int notifID = intent.getExtras().getInt("NotifID");
        //     NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
        //     //---PendingIntent to launch activity if the user selects
        //     // the notification---
        //     Intent notificationIntent = new Intent(context, MainActivity.class);
        //     notificationIntent.putExtra("mytype", "2 minutes later?");
        //     PendingIntent contentIntent = PendingIntent.getActivity(context, notifID, notificationIntent, PendingIntent.FLAG_IMMUTABLE);
        //     //create the notification
        //     Notification notif = new NotificationCompat.Builder(context, MainActivity.id)
        //         .setSmallIcon(R.drawable.ic_launcher)
        //         .setWhen(System.currentTimeMillis()) //When the event occurred, now, since noti are stored by time.
        //         .setContentTitle("Time's up!") //Title message top row.
        //         .setContentText("This is your alert, courtesy of the AlarmManager") //message when looking at the notification, second row
        //         .setContentIntent(contentIntent) //what activity to open.
        //         .setChannelId(MainActivity.id)
        //         .setAutoCancel(true) //allow auto cancel when pressed.
        //         .build(); //finally build and return a Notification.
        //     //Show the notification
        //     nm.notify(notifID, notif);
        // }
    }

    protected static void sendNotification(Context context, Intent intent) {
        Notification.Builder notificationBuilder = aefcaNotificationManager.buildNotification(context, intent);
        int id = intent.getIntExtra("id", -1);

        aefcaNotificationManager.notify(context, id, notificationBuilder.build(), intent);
    }

    // Create a Notification.Builder from the intent.
    @SuppressWarnings("deprecation")
    protected static Notification.Builder buildNotification(Context context, Intent intent) {
        Bundle bundle = intent.getExtras();

        if (bundle != null) {
            for (String key : bundle.keySet()) {
                Object value = bundle.get(key);
                Log.d(TAG, String.format("%s %s (%s)", key,
                        value.toString(), value.getClass().getName()));
            }
        }

        String channelID = intent.getStringExtra("channelID");

        Notification.Builder notificationBuilder;
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            notificationBuilder = new Notification.Builder(context);
        } else {
            notificationBuilder = new Notification.Builder(context, channelID);
        }
        notificationBuilder.setSmallIcon(R.drawable.abc_aefca_ic_notification);
        if (Build.VERSION.SDK_INT >=Build.VERSION_CODES.N) {

        }
        PendingIntent tapIntent = (PendingIntent) intent.getParcelableExtra("tapIntent");
        boolean autoCancel = intent.getBooleanExtra("autoCancel", true);

        notificationBuilder.setContentIntent(tapIntent);
        notificationBuilder.setAutoCancel(autoCancel);

        int number = intent.getIntExtra("number", 0);
        if (number >= 0)
            notificationBuilder.setNumber(number);

        long timestampValue = intent.getLongExtra("timestamp", -1);
        notificationBuilder.setWhen(timestampValue);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT_WATCH) {
            String group = intent.getStringExtra("group");
            if (group != null && group.length() > 0) {
                notificationBuilder.setGroup(group);
            }

            boolean groupSummary = intent.getBooleanExtra("groupSummary", false);
            if (groupSummary)
                notificationBuilder.setGroupSummary(groupSummary);

            String sortKey = intent.getStringExtra("sortKey");
            if (sortKey != null && sortKey.length() > 0) {
                notificationBuilder.setSortKey(sortKey);
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            boolean showTimestamp = intent.getBooleanExtra("showTimestamp", false);
            notificationBuilder.setShowWhen(showTimestamp);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            int color = intent.getIntExtra("color", 0);
            if (color != 0) {
                notificationBuilder.setColor(color);
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    notificationBuilder.setColorized(true);
                }
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP_MR1) {
            boolean usesChronometer = intent.getBooleanExtra("usesChronometer", false);
            notificationBuilder.setUsesChronometer(usesChronometer);
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            // For device below Android O, we use the values from NotificationChannelWrapper to set visibility, priority etc.
            NotificationChannelWrapper fakeNotificationChannel = getNotificationChannel(context, channelID);

            if (fakeNotificationChannel.vibrationPattern != null && fakeNotificationChannel.vibrationPattern.length > 0) {
                notificationBuilder.setDefaults(Notification.DEFAULT_LIGHTS | Notification.DEFAULT_SOUND);
                notificationBuilder.setVibrate(fakeNotificationChannel.vibrationPattern);
            } else {
                notificationBuilder.setDefaults(Notification.DEFAULT_ALL);
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                notificationBuilder.setVisibility((int) fakeNotificationChannel.lockscreenVisibility);
            }

            // Need to convert Oreo channel importance to pre-Oreo priority.
            int priority;
            switch (fakeNotificationChannel.importance) {
                case NotificationManager.IMPORTANCE_HIGH:
                    priority = Notification.PRIORITY_MAX;
                    break;
                case NotificationManager.IMPORTANCE_LOW:
                    priority = Notification.PRIORITY_LOW;
                    break;
                case NotificationManager.IMPORTANCE_NONE:
                    priority = Notification.PRIORITY_MIN;
                    break;
                default:
                    priority = Notification.PRIORITY_DEFAULT;
            }
            notificationBuilder.setPriority(priority);
        } else {
            // groupAlertBehaviour is only supported for Android O and above.
            int groupAlertBehaviour = intent.getIntExtra("groupAlertBehaviour", 0);
            notificationBuilder.setGroupAlertBehavior(groupAlertBehaviour);
        }

        return notificationBuilder;
    }

    public static Bitmap GetImageInputStream(String imageurl) {
        Log.d("Bitmap","---------------------------imageurl"+imageurl);
        URL url;
        HttpURLConnection connection = null;
        Bitmap bitmap = null;
        try {
            url = new URL(imageurl);
            connection = (HttpURLConnection) url.openConnection();
            connection.setConnectTimeout(6000); //超时设置
            connection.setDoInput(true);
            connection.setUseCaches(false); //设置不使用缓存
            InputStream inputStream = connection.getInputStream();
            bitmap = BitmapFactory.decodeStream(inputStream);
            inputStream.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bitmap;
    }



    // Call the system notification service to notify the notification.
    protected static void notify(Context context, int id, Notification notification, Intent intent) {
//        getNotificationManager(context).notify(id, notification);
        Log.i("MyNotificationManager","intent = "+intent);
        try {
            Log.d("MyNotificationManager", "mNotificationCallback========:" + mNotificationCallback);
//            mNotificationCallback.onSendNotification(intent);
            try{
                Log.d("MyNotificationManager", "111111111");
                NotificationCallback m_notification = (NotificationCallback)Class.forName("org.cocos2dx.lua.aefcaNotificationCallback")
                        .newInstance();
                if(null != m_notification){
                    Log.d("MyNotificationManager", "222222222");
                    m_notification.onSendNotification(context,intent);
                }
            }catch(Exception e){

            }
        } catch (RuntimeException ex) {
            ex.printStackTrace();
            Log.w("MyNotificationManager", "Can not invoke OnNotificationReceived event when the app is not running!");
        }

        boolean isRepeatable = intent.getLongExtra("repeatInterval", 0L) > 0;

        if (!isRepeatable)
            aefcaNotificationManager.deleteExpiredNotificationIntent(context, Integer.toString(id));
    }
}
