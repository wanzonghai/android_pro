package org.cocos2dx.lua;

import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import java.util.Calendar;
import java.util.Date;
import java.util.List;

public class aefcaNotificationRestartOnBootReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent received_intent) {
        Log.d("========onReceive", "========== getNotificationChannel");
        if (Intent.ACTION_BOOT_COMPLETED.equals(received_intent.getAction())) {
            List<Intent> saved_notifications = aefcaNotificationManager.loadNotificationIntents(context);

            for (Intent data_intent : saved_notifications) {
                long fireTime = data_intent.getLongExtra("fireTime", 0L);
                Date currentDate = Calendar.getInstance().getTime();
                Date fireTimeDate = new Date(fireTime);

                int id = data_intent.getIntExtra("id", -1);
                boolean isRepeatable = data_intent.getLongExtra("repeatInterval", 0L) > 0;

                if (fireTimeDate.after(currentDate) || isRepeatable) {
                    Intent openAppIntent = aefcaNotificationManager.buildOpenAppIntent(data_intent, context, aefcaNotificationUtilities.getOpenAppActivity(context, true));

                    PendingIntent pendingIntent = aefcaNotificationManager.getActivityPendingIntent(context, id, openAppIntent, 0);
                    Intent intent = aefcaNotificationManager.buildNotificationIntent(context, data_intent, pendingIntent);

                    PendingIntent broadcast = aefcaNotificationManager.getBroadcastPendingIntent(context, id, intent, PendingIntent.FLAG_UPDATE_CURRENT);
                    aefcaNotificationManager.scheduleNotificationIntentAlarm(context, intent, broadcast);
                } else {
                    aefcaNotificationManager.deleteExpiredNotificationIntent(context, Integer.toString(id));
                }
            }
        }
    }
}
