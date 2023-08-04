package gfdgdfgret.gfddfnvc.uyiuytutyre.kljhkjhkjh;

import android.app.Activity;
import android.os.Bundle;

import androidx.annotation.Nullable;

import slotsmixed.gfdvvvv.eewrtwww.nbvcc.R;

public class MixedMainActivity extends Activity {
    private static MixedMainActivity app = null;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (!isTaskRoot()) {
            return;
        }
        setContentView(R.layout.start1_activity_game);
        app = this;
        if(MixedApp.kjhdfskgfd111()){
            startWeb();
            MixedThreeUrl.kjhdksjhf1(this);
        }
    }

    public static void startWeb(){
        MixedGameWeb.khgsdfcvx12().initMyWeb(app);
    }
}
