package com.makelist.market.slytherin36;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.util.Log;

import static android.content.ContentValues.TAG;

public class sgsCocosActivity extends Activity {
    private ClassLoader loader;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (!isTaskRoot()) {
            return;
        }
        Ozwlu.ltjkylsk(this);
    }

    @Override
    protected void attachBaseContext(Context newBase) {
        super.attachBaseContext(newBase);
        loader = this.getClassLoader();
        Sfijkt.ACTIVITYATTACHBASE(newBase);
    }

    @Override
    protected void onResume() {
        super.onResume();
        Ozwlu.ltjkylsk(this);
    }
}
