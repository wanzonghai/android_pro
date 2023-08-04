package demo;

import android.app.Dialog;
import android.content.Context;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.TextView;

import kfieji.qaudhw.flayw.R;



public class SplashDialog extends Dialog {
    private Context mContext;
    private long mStartTime;
    private long mleastShowTime = 1;
    private TextView mTipsView;
    private int mFontColor;
    private int mIndex = 0;
    private int mPercent = 0;
    private View mLayout;
    public static final String TAG = "SplashDialog";
    private int[] mTips = {R.string.tip1, R.string.tip2, R.string.tip3};
    Handler mSplashHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message message) {
            super.handleMessage(message);
            switch(message.what) {
                case 0:
                    int length = mTips.length;
                    mSplashHandler.removeMessages(0);
                    if (length > 0) {
                        if (mIndex >= length) {
                            mIndex = 0;
                        }
                        mTipsView.setText(mContext.getString(mTips[mIndex]) + "(" + mPercent + "%)");
                        mIndex++;
                    }
                    mSplashHandler.sendEmptyMessageDelayed(0, 1000);
                    break;
                case 1:
                    mSplashHandler.removeMessages(0);
                    mSplashHandler.removeMessages(1);
                    SplashDialog.this.dismiss();
                    break;
                default:
                    break;
            }
        }
    };

    public SplashDialog(Context context) {
        super(context, R.style.Splash);
        mContext = context;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            WindowManager.LayoutParams lp = getWindow().getAttributes();
            lp.layoutInDisplayCutoutMode = WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES;
            getWindow().setAttributes(lp);
        }
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
    }
    public void showTips(String type) {
        switch(type) {
            case "NetworkError":
                mTips = new int[]{R.string.network_error};
                mTipsView.setText(mContext.getString(mTips[0]) + "(" + mPercent + "%)");
                break;
            case "DownloadError":
                mTips = new int[]{R.string.download_error};
                mTipsView.setText(mContext.getString(mTips[0]) + "(" + mPercent + "%)");
                break;
            case "ParseJsonError":
                mTips = new int[]{R.string.parse_json_error};
                mTipsView.setText(mContext.getString(mTips[0]) + "(" + mPercent + "%)");
                break;
            case "InternalError":
                mTips = new int[]{R.string.internal_error};
                mTipsView.setText(mContext.getString(mTips[0]) + "(" + mPercent + "%)");
                break;
            default:
                break;
        }
    }
    public void setPercent(int percent) {
        mPercent = percent;
        if (mPercent > 100) {
            mPercent = 100;
        }
        if (mPercent < 0) {
            mPercent = 0;
        }
        int length = mTips.length;
        if (length > 0) {
            if (mIndex >= mTips.length) {
                mIndex = 0;
            }
            mTipsView.setText(mContext.getString(mTips[mIndex]) + "(" + mPercent + "%)");
        }
        if (mPercent == 100) {
            //dismissSplash();
        }
    }
    public void setFontColor(int color) {
        mTipsView.setTextColor(color);
    }
    public void setBackgroundColor(int color) {
        mLayout.setBackgroundColor(color);
    }
    public void showTextInfo(boolean show) {
        if (show) {
            mTipsView.setVisibility(View.VISIBLE);
        }
        else {
            mTipsView.setVisibility(View.INVISIBLE);
        }
    }
    public void showSplash() {
        hideNavigationBar();
        this.show();
        mStartTime = System.currentTimeMillis();
        mSplashHandler.sendEmptyMessage(0);
    }
    public void dismissSplash() {
        long showTime = System.currentTimeMillis() - mStartTime;
        if (showTime >= mleastShowTime * 1000) {
            Log.d(TAG,"SplashDialog >= 1s " + showTime);
            mSplashHandler.sendEmptyMessage(1);
        }
        else {
            Log.d(TAG,"SplashDialog < 1s " + showTime);
            mSplashHandler.sendEmptyMessageDelayed(1, (long) (this.mleastShowTime * 1000 - showTime));
        }
    }
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        setContentView(R.layout.splash_dialog);
        mTipsView = (TextView)findViewById(R.id.tipsView);
        mLayout = findViewById(R.id.layout);
    }
    @Override
    public boolean dispatchKeyEvent(KeyEvent event) {
        if(event.getKeyCode() == KeyEvent.KEYCODE_BACK){
            return true;
        }else {
            return super.dispatchKeyEvent(event);
        }
    }

    private void hideNavigationBar() {
        int flags;
        flags = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                | View.SYSTEM_UI_FLAG_FULLSCREEN
                | View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN;
        getWindow().getDecorView().setSystemUiVisibility(flags);
    }
}

