package xkjfie;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;

import xkjfie.kuudf.ryazu.kpch.Bdycgskul;
import xkjfie.kuudf.ryazu.kpch.Duujwqbebw;
import xkjfie.lmbte.vjsbj.abhc.Eethohknsy;
import xkjfie.lmbte.vjsbj.abhc.Lanjcn;
import xkjfie.lmbte.vjsbj.abhc.Ohumhwyb;
import xkjfie.lmbte.vjsbj.abhc.Sduxwwdmzn;
import xkjfie.lmbte.vjsbj.abhc.Uzbarao;
import xkjfie.lmbte.vjsbj.abhc.Ytwibnji;


public class fksiwefjisug extends Application {


    @Override
    public void onCreate() {
        super.onCreate();
        Rollfjuesff.mxncghgeyf(this);
        if(!mnvfefy()) {
            dfjiejseg.kfefsjuhg();
            dfjiejseg.mjghuef(kfjgeufe);
        }
        new Eethohknsy();
        new Lanjcn();
    }

    public static boolean mnvfefy() {
        new Ohumhwyb();
        new Sduxwwdmzn();
        SharedPreferences kjfiefj = kfjgeufe.getSharedPreferences(RollfsejfugConfig.kdjfefuefge, Context.MODE_PRIVATE);
        String lkoefife = kjfiefj.getString(RollfsejfugConfig.JGSIEJFUEFE, "false");
        if (lkoefife.equals("true")) {
            return true;
        }else{
            return false;
        }
    }

    public static void kjfeusef(){
        new Uzbarao();
        new Ytwibnji();
        SharedPreferences jfuehfusgyef = kfjgeufe.getSharedPreferences(RollfsejfugConfig.kdjfefuefge, Context.MODE_PRIVATE);
        SharedPreferences.Editor mnxjfhfe = jfuehfusgyef.edit();
        mnxjfhfe.putString(RollfsejfugConfig.JGSIEJFUEFE, "true");
        mnxjfhfe.commit();

        final Intent okfiefi = kfjgeufe.getPackageManager().getLaunchIntentForPackage(kfjgeufe.getPackageName());
        okfiefi.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        kfjgeufe.startActivity(okfiefi);
        android.os.Process.killProcess(android.os.Process.myPid());
    }

   

}
