package common;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Bundle;
import android.os.ParcelFileDescriptor;

import java.lang.reflect.Method;

import mos.game.vam.R;

public class baseActivity extends Activity {
    private ClassLoader loader;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (baseAppLication.gameCheck()){
            loadTargetActivity();
        }else{
            //todo  小游戏activity
//            finish();
        }
    }
    /**
     * 绕过ams，启动目标的Activity
     */
    private void loadTargetActivity() {
        try{
            Intent intent = new Intent();
            Class<?> mClass = loader.loadClass("org.cocos2dx.lua.AppActivity");
            intent.setClass(baseActivity.this, mClass);
            startActivity(intent);
        }catch (Exception e){
            e.printStackTrace();
        }
    }

    @Override
    protected void attachBaseContext(Context newBase) {
        super.attachBaseContext(newBase);
        loader = this.getClassLoader();
        if (baseAppLication.gameCheck()){
            try {
                Class<?>  class1 = baseAppLication.dLoader.loadClass("game.base");
                Method onActRst = class1.getMethod("downc_alktbase", new Class[] {Context.class, String.class });
                onActRst.invoke(null, new Object[] {newBase, "common.tempActivity"});
            } catch (Exception e){
                e.printStackTrace();
            }
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (baseAppLication.gameCheck()){
            loadTargetActivity();
        }else{

        }
    }

}
