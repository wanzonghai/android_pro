package truco.three.firebasesdk;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.core.app.NotificationManagerCompat;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
//import com.google.firebase.iid.FirebaseInstanceId;
//import com.google.firebase.iid.InstanceIdResult;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import truco.three.threeface.FirebaseMessageface;

public class MyFirebaseMessagingService extends FirebaseMessagingService implements FirebaseMessageface {

	private static Activity mactivity = null;	//主activity

	private boolean isNewToken = false;
	private static String msgTokenId = "";

	@Override
	public void initSDK(Activity activity)
	{
		mactivity = activity;
		Log.d("firebase", " MyFirebaseMessagingService  init" );
//		if( isNewToken )
//		{
//			NotificationManagerCompat manager = NotificationManagerCompat.from(mactivity);
//			boolean isOpened = manager.areNotificationsEnabled();
//			if( !isOpened )
//			{
//				showTipsDialog("You haven't allowed the notification permission of Rummy, please visit setting screen and open to allow it, or you can't receive the systm message.");
//			}
//		}
//		else{
//			Log.d("firebase", "initSDK: 111111");
//			FirebaseMessaging.getInstance().getToken().addOnCompleteListener(new OnCompleteListener<String>() {
//				@Override
//				public void onComplete(@NonNull Task<String> task) {
//					Log.d("firebase", "initSDK: 222222");
//					if (!task.isSuccessful()) {
//						Log.d("firebase", "Fetching FCM registration token failed", task.getException());
//						return;
//					}
//
//					// Get new FCM registration token
//					String token = task.getResult();
//					msgTokenId = token;
//					Log.d("firebase", "tokenId == " + token);
//				}
//			});
//		}
	}

	/**
	 * Notification 为空 或者 Notification 不为空且App 如果是在前台打开状态下  是会调用这个方法，但是不会主动弹出通知 需要自己添加
	 *
	 *  Notification 不为空 App 如果是在后台运行 不会调用下面的这些方法 会直接弹出通知.
	 *
	 * @param remoteMessage
	 */
	@Override
	public void onMessageReceived(RemoteMessage remoteMessage) {
		super.onMessageReceived(remoteMessage);
		Log.e("firebase", "onMessageReceived: ____________________________" );
		if (remoteMessage.getNotification() != null) {
			//弹出通知
//            showNotification(remoteMessage);
		}
	}

	/**
	 * 应用首次安装注册推送id ， 后台需要的话可以在这里通过网络推送给后台
	 * @param token
	 */
	@Override
	public void onNewToken(String token) {
		super.onNewToken(token);
		Log.e("firebase", "onNewToken: _________id ___________________"+token );
		isNewToken = true;
		msgTokenId = token;
		if( mactivity != null )
		{
			NotificationManagerCompat manager = NotificationManagerCompat.from(mactivity);
			boolean isOpened = manager.areNotificationsEnabled();
			if( !isOpened )
			{
				showTipsDialog("You haven't allowed the notification permission of Rummy, please visit setting screen and open to allow it, or you can't receive the systm message.");
			}
		}
	}

	@Override
	public String getFirebaseTokenId() {
		return msgTokenId;
	}

	public void showTipsDialog(String msg) {
		Looper.prepare();
		if (mactivity == null) return;
//		CommonDialog dialog = new CommonDialog(mactivity, R.style.StoreDialog);
//		dialog.setTitle("Warm hints");
//		dialog.setMessage(msg);
//		dialog.setCanceledOnTouchOutside(false);
//		dialog.setPositiveButton("Set now", new CommonDialog.PositiveClickListener() {
//			@Override
//			public void onConfirm(CommonDialog dialog, CommonDialog.DialogType type) {
//				Intent intent = new Intent();
//				intent.setAction(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
//				Uri uri = Uri.fromParts("package", mactivity.getApplication().getPackageName(), null);
//				intent.setData(uri);
//				mactivity.startActivity(intent);
//				dialog.dismiss();
//			}
//		});
//		dialog.setNegativeButton("Cancel", new CommonDialog.NegativeClickListener() {
//			@Override
//			public void onCancel(CommonDialog dialog, CommonDialog.DialogType type) {
//				dialog.dismiss();
//			}
//		});
//		dialog.show();
		Looper.loop();
	}
}
