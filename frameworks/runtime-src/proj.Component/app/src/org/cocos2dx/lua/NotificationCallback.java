package org.cocos2dx.lua;

import android.content.Context;
import android.content.Intent;

public interface NotificationCallback {
    void onSendNotification(Context context,Intent intent);
}
