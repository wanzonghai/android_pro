package truco.three.firebasesdk;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

import com.google.firebase.analytics.FirebaseAnalytics;

import truco.three.threeface.FireBaseInterface;

public class FireBaseSDK implements FireBaseInterface {
	private static Activity mactivity = null;	//主activity
	private static FirebaseAnalytics mFirebaseAnalytics = null;

	@Override
	public void initSDK(Activity activity) {
		Log.d("FireBaseSDK", "initSDK ");
		mactivity = activity;
		mFirebaseAnalytics = FirebaseAnalytics.getInstance(mactivity);
	}
}
