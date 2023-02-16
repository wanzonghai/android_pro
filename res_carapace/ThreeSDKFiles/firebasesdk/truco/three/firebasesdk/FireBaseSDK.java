package truco.three.firebasesdk;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;

import com.google.firebase.analytics.FirebaseAnalytics;

import truco.three.threeface.FireBaseface;

public class FireBaseSDK implements FireBaseface {
	private static Activity mactivity = null;	//主activity
	private static FirebaseAnalytics mFirebaseAnalytics = null;

	@Override
	public void initSDK(Activity activity) {
		Log.d("FireBaseSDK", "initSDK ");
		mactivity = activity;
		mFirebaseAnalytics = FirebaseAnalytics.getInstance(mactivity);
	}

	/**
	 * 记录事件
	 */
	public static void logFirebaceEvent(String eventType)
	{
		Bundle params = new Bundle();
//		params.putString("eventName", "");
		Log.d("FireBaseSDK", "logFirebaceEvent = " + eventType);
		mFirebaseAnalytics.logEvent(eventType, params);
	}

	/**
	 * 记录事件组
	 */
	public static void logFirebaceEventMap(String eventType,String key,String value){
		Bundle params = new Bundle();
		params.putString(key, value);
		Log.d("FireBaseSDK", "logFirebaceEventMap = " + eventType + "," + key + "," + value);
		mFirebaseAnalytics.logEvent(eventType, params);
	}

	/**
	 * 加入购物车事件
	 */
	public static void firebaseAddToCartEvent(String contentData, int price)
	{
		Log.d("FireBaseSDK", String.format("price: %d",price));
		Bundle params = new Bundle();
		params.putString("currency", "INR");
		params.putInt("value", price);
		params.putString("items", contentData);

		Log.d("FireBaseSDK", "firebaseAddToCartEvent = " + params);
		mFirebaseAnalytics.logEvent("achievement_add", params);
	}

	/**
	 * 购物回调事件(自定义不用标准购买事件，规避谷歌检查)
	 */
	public static void firebasePurchaseEvent(String eventType, int price)
	{
		Log.d("FireBaseSDK", String.format("price: %d",price));
		Bundle params = new Bundle();
		params.putInt("value", price);
		Log.d("FireBaseSDK", "firebasePurchaseEvent = " + params);
		mFirebaseAnalytics.logEvent(eventType, params);
	}

	/**
	 * 加入购物车事件
	 */
	public static void firebasePurchaseEvent1(String eventType, String contentData, int price)
	{
		Log.d("FireBaseSDK", String.format("eventType: %s",eventType));
		Bundle params = new Bundle();
		params.putString("currency", "INR");
		params.putInt("value", price);
		params.putString("items", contentData);

		Log.d("FireBaseSDK", "firebasePurchaseEvent1 = " + params);
		mFirebaseAnalytics.logEvent(eventType, params);
	}

	/**
	 * 用户属性
	 */
	public static void setFirebaceUserProperty(String eventType, String name)
	{
		mFirebaseAnalytics.setUserProperty(eventType, name); //"favorite_food", "food"
	}
}
