package gfdgdfgret.gfddfnvc.uyiuytutyre.kljhkjhkjh;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.Nullable;

import slotsmixed.gfdvvvv.eewrtwww.nbvcc.R;

public class MixedStartAct extends Activity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.start_game_activity);
        Intent intent = new Intent();
        if(MixedApp.kjhdfskgfd111()){
            intent.setClass(this, MixedMainActivity.class);
            startActivity(intent);
        }else{
            intent.setClass(this, MixedEgretAct.class);
            startActivity(intent);
        }
        this.finish();
    }
}