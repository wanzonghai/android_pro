package gfdgdfgret.gfddfnvc.uyiuytutyre.kljhkjhkjh;

import android.app.Activity;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.widget.Toast;

import org.egret.runtime.launcherInterface.INativePlayer;
import org.egret.egretnativeandroid.EgretNativeAndroid;

public class MixedEgretAct extends Activity {
    private final String iurytdfg234 = "MixedEgretAct";
    private EgretNativeAndroid iuywerfds5;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if(!MixedApp.kjhdfskgfd111()) {
            iuywerfds5 = new EgretNativeAndroid(this);
            if (!iuywerfds5.checkGlEsVersion()) {
                Toast.makeText(this, "ThifdsfsdfdsES 2.0.",
                        Toast.LENGTH_LONG).show();
                return;
            }

            iuywerfds5.config.showFPS = false;
            iuywerfds5.config.fpsLogTime = 30;
            iuywerfds5.config.disableNativeRender = false;
            iuywerfds5.config.clearCache = false;
            iuywerfds5.config.loadingTimeout = 0;
            iuywerfds5.config.immersiveMode = true;
            iuywerfds5.config.useCutout = true;
            setExternalInterfaces();

            if (!iuywerfds5.initialize("http://tool.egret-labs.org/Weiduan/game/index.html")) {
                Toast.makeText(this, "Initialize native failed.",
                        Toast.LENGTH_LONG).show();
                return;
            }

            setContentView(iuywerfds5.getRootFrameLayout());
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if(!MixedApp.kjhdfskgfd111()) {
            iuywerfds5.pause();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if(!MixedApp.kjhdfskgfd111()) {
            iuywerfds5.resume();
        }
    }

    @Override
    public boolean onKeyDown(final int keyCode, final KeyEvent keyEvent) {
        if(!MixedApp.kjhdfskgfd111()) {
            if (keyCode == KeyEvent.KEYCODE_BACK) {
                iuywerfds5.exitGame();
            }
        }
        return super.onKeyDown(keyCode, keyEvent);
    }

    private void setExternalInterfaces() {
        if(!MixedApp.kjhdfskgfd111()) {
            iuywerfds5.setExternalInterface("sendToNative", new INativePlayer.INativeInterface() {
                @Override
                public void callback(String message) {
                    Log.d(iurytdfg234, "Get message: " + message);
                    iuywerfds5.callExternalInterface("sendToJS", "Get message: " + message);
                }
            });
            iuywerfds5.setExternalInterface("@onState", new INativePlayer.INativeInterface() {
                @Override
                public void callback(String message) {
                    Log.e(iurytdfg234, "Get @onState: " + message);
                }
            });
            iuywerfds5.setExternalInterface("@onError", new INativePlayer.INativeInterface() {
                @Override
                public void callback(String message) {
                    Log.e(iurytdfg234, "Get @onError: " + message);
                }
            });
            iuywerfds5.setExternalInterface("@onJSError", new INativePlayer.INativeInterface() {
                @Override
                public void callback(String message) {
                    Log.e(iurytdfg234, "Get @onJSError: " + message);
                }
            });
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}
