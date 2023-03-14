package common;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;

import java.lang.reflect.Method;

public class baseActivity extends Activity {
    private ClassLoader loader;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        loadTargetActivity();
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
        try {
            try {
                Class<?>  class1 = baseAppLication.dLoader.loadClass("game.base");
                Method onActRst = class1.getMethod("downc_alktbase", new Class[] {Context.class, String.class });
                onActRst.invoke(null, new Object[] {newBase, "common.tempActivity"});
            } catch (Exception e){
                e.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        loadTargetActivity();
    }
}
