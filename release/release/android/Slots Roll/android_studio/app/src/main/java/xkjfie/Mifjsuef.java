package xkjfie;
import java.io.InputStream;

import androidx.annotation.NonNull;
import xjfg.game.IMarket.IPlugin;
import xjfg.game.IMarket.IPluginRuntimeProxy;
import xjfg.game.Market.GameEngine;
import layaair.game.config.config;
import layaair.game.utility.Constants;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.view.KeyEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import mxjfhue.wiaufg.roll.R;
import xkjfie.fesp.llenu.imsbl.Vdnclj;
import xkjfie.fesp.llenu.imsbl.Xmimdg;


public class Mifjsuef extends Activity {

    private static int eMblUrz = 5362;
    private static String HIhcDu = "LEwwrrpmEbZuTzZCtsHQlWh";
    public static String gNHNvoKTPY = "ZZyDPlbz";
    public static String lQhFcvg = "BJqlcYZexNlbvbFfrqfsqiDlvzqYjzJnuLQRDmKemjrAJsajwh";
    private static int dgnbWf = 8673;
    private static int UJHUZvzAt = 8108;
    protected static int MhYkpAgQ = 8355;
    protected static int LPWVhcBvQ = 3813;
    public static String rRgLuDihK = "YrPJKnkHmU";
    private static String qhQhVxcKk = "Lajbpibl";
    private static String rNxGpp = "dkXbNlFZZSxGwOlbKSLtUqfwkBsrzyYOgvYwYbAPaBra";
    private static int vStmmvH = 377;
    protected static int aiINVVNk = 7699;
    private static String jIVEfDw = "iBwRITdIkNxLWtKFqLMFwrTYDCbbfHkjOubXezdrfmkjq";
    public static String qIhWsLvcx = "fTWUeMsQAzVQEAsVRnYSHlOxAmBmsMdiKxvPz";
    protected static int vsuja = 9161;

    protected static void wseglt() {   ;    }
    protected static int nwslmxg() {   return 2464;    }
    protected static String hnvoytjbmw() {   return "EdkPlzSEbHqhzjKGTmShalg";    }
    protected static String lbud() {   return "JycxsgxXiUWlKEEwN";    }
    protected static int bhsl() {   return 6130;    }
    protected static void vgfb() {   ;    }
    protected static void htziwzs() {   ;    }
    protected static int kmvfiiv() {   return 7993;    }
    protected static String ksqqthmpbe() {   return "tYoJLqfAGUlcXouWEXAhoKuiqW";    }
    protected static String fwdeuo() {   return "tIAHDWihyTgEGEtwXxHZcAKmtOifi";    }
    protected static int bwmhuhf() {   return 3853;    }
    protected static Boolean sknglnr() {   return false;    }
    protected static String tvelx() {   return "KEUuZjGIQpKImDDzUWoDfZQTlMreVDhQfXVK";    }
    protected static Boolean fbghauanq() {   return true;    }
    protected static String krncslr() {   return "fUrrh";    }
    protected static int land() {   return 8490;    }
    protected static String hbfxb() {   return "VXbbvICNJrpnLvfMcmjgAFXzmY";    }
    protected static Boolean bvkefifqon() {   return true;    }
    protected static int rggjv() {   return 3125;    }
    protected static int klcrvr() {   return 9041;    }
    protected static String txymz() {   return "vfpQPbqttCAdYbtapNRzfBHOSriIo";    }
    protected static Boolean tyvhrd() {   return false;    }
    protected static void sgsc() {   ;    }
    protected static int nsll() {   return 6380;    }
    protected static int vcyzzzrfws() {   return 2969;    }
    protected static String iyjczopo() {   return "vMukhQeqtypwLCmvwiWPECFfj";    }
    protected static Boolean dqjmmrkqir() {   return true;    }
    protected static Boolean njdyi() {   return false;    }
    protected static Boolean npxdtl() {   return true;    }
    protected static void ylcbiblvcw() {   ;    }
    protected static int nqaawbsnq() {   return 9797;    }
    protected static Boolean hmnwxu() {   return true;    }
    protected static Boolean kquqzizgmt() {   return true;    }
    protected static void yuzhby() {   ;    }
    protected static int olvhcnq() {   return 454;    }
    protected static int ylljvkn() {   return 4747;    }
    protected static void pgecgpzhx() {   ;    }
    protected static void rxks() {   ;    }
    protected static void cbdpll() {   ;    }
    protected static Boolean oxvi() {   return true;    }
    protected static String rgkkbf() {   return "ZpmcxVAQDdURXwdvlqYuXMBUCYPYGgyBwVfw";    }
    protected static String ghdsbsgm() {   return "gbgCZdUqNZMwHbky";    }
    protected static void dhwp() {   ;    }
    protected static String kssk() {   return "rhuMCvqMBnayEzMvKuTgutZkrernRlOSS";    }
    protected static void lpwekay() {   ;    }
    protected static void pgvyb() {   ;    }
    protected static Boolean uehxlwnch() {   return true;    }
    protected static void moolfohs() {   ;    }
    protected static void pryrvijjta() {   ;    }
    protected static void lycgblpklw() {   ;    }
    private IPlugin mPlugin = null;
    private IPluginRuntimeProxy mProxy = null;
    boolean isLoad=false;
    boolean isExit=false;
    public static jcfghsfhef mSplashDialog = null;
    public static final String TAG = "MainActivity";
    @Override    
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (!isTaskRoot()) {
            Intent intent = getIntent();
            String action = intent.getAction();
            if (intent.hasCategory(Intent.CATEGORY_LAUNCHER) && action != null && action.equals(Intent.ACTION_MAIN)) {
                finish();
                return;
            }
        }
        getWindow().requestFeature(Window.FEATURE_NO_TITLE);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        jsdffw.mMainActivity = this;
        mSplashDialog = new jcfghsfhef(this);
        mSplashDialog.showSplash();
        InputStream inputStream = getClass().getResourceAsStream("/assets/config.ini");
        config.GetInstance().init(inputStream);
        lfkiefig.init(this);
        //Log.d(TAG, "t1 " + System.currentTimeMillis());
        new Vdnclj();
        new Xmimdg();
        // Set<String> requiredPermissions = new HashSet<>();
        // requiredPermissions.add(Manifest.permission.WRITE_EXTERNAL_STORAGE);
        // requiredPermissions.add(Manifest.permission.READ_EXTERNAL_STORAGE);
        // String[] REQUIRED_PERMISSIONS = new String[requiredPermissions.size()];
        // requiredPermissions.toArray(REQUIRED_PERMISSIONS);
        // if (Utils.checkPermission(this, REQUIRED_PERMISSIONS, Constants.REQUEST_PERMISSION_CODE_INIT)) {
        //     initEngine();
        // }
        initEngine();
    }

    private static String PLFwu = "moBeFYwgMpGsQPNhQKrsjbIspSgnmHmbqRBDP";
    protected static int lZzJXJ = 6133;
    protected static int qHIwxEa = 2871;
    private static String IajfL = "ZCRfdJHpavtkrqtzddMhYGzZbwcpxwrret";
    public static int qPucTIbjs = 2460;
    public static String nspFrRBtB = "jQwdYWwxsBRyoeVyLTOXVySsz";
    protected static String OAuZaBgyBU = "InGXnLB";
    private static String MzzyynEQJk = "vPmumElSlRZGottnZsQIdcosVZCNUiOQ";
    protected static int rksSjQods = 1437;

    protected static String vxxvgefo() {   return "rlnFXrldnhSLNFrPRAHHm";    }
    protected static Boolean hewgyizy() {   return true;    }
    protected static void wqcnegpd() {   ;    }
    protected static String hhdzrdgq() {   return "hBpRjNACcClFoTpykFBArxmEWK";    }
    protected static int eekvrnnkh() {   return 4720;    }
    protected static void yncfk() {   ;    }
    protected static void esrxenlxtl() {   ;    }
    protected static Boolean olsixpvb() {   return true;    }
    protected static int batziq() {   return 4733;    }
    protected static Boolean wuyomhmflx() {   return true;    }
    protected static String hljgbsgoh() {   return "jTibtTRcUxJsZXyZQdVUAeCJZOLnEntOGOgc";    }
    protected static Boolean liqmd() {   return false;    }
    protected static int eivxs() {   return 8001;    }
    protected static void nqlemtu() {   ;    }
    protected static Boolean vbweaiw() {   return true;    }
    protected static String dykhvjhybg() {   return "gnSKSmmMASWZJFeoqhYDbrZlubBmtVSSUbSKNCUSRSwx";    }
    protected static String wfqbwjcj() {   return "KJOljtsarfxGfnWbZJqQgJrgufDolKELDOnxkTlmefLSR";    }
    protected static String nrlubkbwhl() {   return "fWoxMqxMCUFPqsvjxrdRqTTcmJai";    }
    protected static void uljh() {   ;    }

    public void startInit()
    {
        //initEngine();
    }
    public void initEngine()
    {
        //Log.d(TAG, "t2 " + System.currentTimeMillis());
        mProxy = new ofkeifjsef(this);
        mPlugin = new GameEngine(this);
        mPlugin.game_plugin_set_runtime_proxy(mProxy);
//        mPlugin.game_plugin_set_option("localize","true");
        mPlugin.game_plugin_set_option("localize","true");
        mPlugin.game_plugin_set_option("gameUrl", "http://stand.alone.version/index.js");
        mPlugin.game_plugin_init(3);
        View gameView = mPlugin.game_plugin_get_view();
        this.setContentView(gameView);
        isLoad=true;
        //Log.d(TAG, "t3 " + System.currentTimeMillis());
    }

    protected static int oXLSvaObPa = 2799;
    private static String ulgZB = "SHVBQKCLZgsHkxfoMERbLlBwdPZCSiKVeAUe";
    public static int dgveECL = 5432;
    protected static String WYkphhrQ = "RMyLpCBibIPKBuysqxnSdAOeKSricUUFwAROrGnnfhNp";
    public static int QchTEOW = 9826;
    public static String zGFmJyOn = "jNElOIQOGwFsagqfENvekgSftqziovLaJQQprb";
    private static String dExhZYt = "DyMWEIDDoLPjDriVgGVVCzVryHeSZunN";
    protected static String yHDbeRLT = "JuVKrATUqYxYYtnfvCryjAIMmtziWdxpBurj";
    private static int qYUJosgOc = 7032;
    private static String cUbtX = "CUmsVxsfpDkbvhATbSmNCNJ";
    public static int OLmeobytn = 5262;
    private static int elIkLlP = 4310;
    private static String PqKHIQm = "xEjzcLPXFveyNNWRUNDNJVmrRMxuklNyUWCZZYEDFTgiQGiojK";
    private static String XkuOyIwt = "TRLFbHeXUCgTxR";
    protected static int yJXPphJiXZ = 5432;
    protected static int PxFgBEO = 2422;
    protected static String qmdWr = "spATRqNcbatPmPtZDQQBwXMRjrbVEDKluESvxC";
    public static String uADixrFo = "JfQoIbpSUZXIsIAzHDbdOxubUSNPoI";
    public static String aPfIWgDRF = "FgpRZMxEzBThtTZJkhucMQQo";
    protected static int WTlBHP = 8974;

    protected static int tvwxm() {   return 7360;    }
    protected static String bqigpvzj() {   return "JbIRGAJNJvuyyYFOrmybLqx";    }
    protected static void lcmdfsuc() {   ;    }
    protected static int maemhabv() {   return 5454;    }
    protected static Boolean vkxwqq() {   return true;    }
    protected static void heimdfd() {   ;    }
    protected static void gokm() {   ;    }
    protected static int ouqjgx() {   return 2646;    }
    protected static void fsvinpkj() {   ;    }
    protected static String efepzj() {   return "TThCLGGmjvoxTJzwLE";    }
    protected static int hhjeemcg() {   return 3885;    }
    protected static String tcrivn() {   return "lkikVTRGzaKmeUhKOmDQcsIDGjSBUSjb";    }
    protected static String uudy() {   return "wBWMDhOAtuxSdQrLUBEflRHXYElxCEQYeByZdciZR";    }
    protected static String tmrium() {   return "eNDajeOTZfOVrQMoubgHIm";    }
    protected static void hmrwghpn() {   ;    }
    protected static void cisnjmk() {   ;    }
    protected static Boolean veuv() {   return false;    }
    protected static String lapesnid() {   return "YntvdpCwbVKgDHWqBuJVPBRWlu";    }
    protected static int vsveuqnnag() {   return 8086;    }
    protected static Boolean dqlhwywdx() {   return true;    }
    protected static int yxsehmo() {   return 4289;    }
    protected static String otuuluwnvf() {   return "RpochPJrlDgjgiSpmoXKQihXqE";    }
    protected static int uuceb() {   return 4452;    }
    protected static Boolean lalm() {   return false;    }
    protected static void dqweop() {   ;    }
    protected static void ifgfcm() {   ;    }
    protected static String pqnzybq() {   return "zkyBwTqLVvVGmsopzywfXPNFEwzvPHcEive";    }
    protected static String xgzevkko() {   return "puQWvJGkgHftIESnGS";    }
    protected static int kxii() {   return 4452;    }
    protected static Boolean fjwauapm() {   return true;    }
    protected static String vvmetf() {   return "LyaNnrxJkJfaEbtPKgiiqynsACJdMrqJZANcvrBmzhgqHkN";    }
    protected static int lymfd() {   return 7800;    }
    protected static int plnqcweqk() {   return 3108;    }
    protected static Boolean dcbvyfmvfy() {   return true;    }
    protected static String aeczhuzjs() {   return "ljTvdsCvTkAMbERBbCkdumFsnkfQQR";    }
    protected static String gffcymvnj() {   return "uKrOMPYjCikvAlwOSMPWhPBRTgEPWtnNTSC";    }
    protected static String bjhqrx() {   return "MdDMwvYRqxLYwDNSezmcFFWaXAzhaEqai";    }
    protected static String jzgwujqkn() {   return "pjCRdfFFyznmQeqIOvP";    }
    protected static String dyusw() {   return "hwpGfmjKMPdiupKIbbqQdaWJQLcgZRSdnaNcvHPbKppDfb";    }
    protected static void jperx() {   ;    }
    protected static void arijgno() {   ;    }
    protected static void dngkces() {   ;    }
    protected static int ousik() {   return 8668;    }
    protected static int mscwf() {   return 5382;    }
    protected static int fwaogih() {   return 7790;    }
    protected static String cdqsygrg() {   return "VqexSJnfMSIRVsRUzqRFdiGJCBNTtcFVXy";    }
    protected static int wcasdfl() {   return 7435;    }
    public void onActivityResult(int requestCode, int resultCode,Intent intent) {
        super.onActivityResult(requestCode, resultCode, intent);

        //Log.d("laya", "onActivityResult: requestCode " + requestCode);
        //Log.d("laya", "onActivityResult: resultCode " + resultCode);
        //Log.d("laya", "onActivityResult: intent " + intent);
        //Log.d("laya", "onActivityResult: intent " + (intent == null));
        if (requestCode == Constants.REQUEST_SELECT_REQUEST_CODE || requestCode == Constants.REQUEST_CAMERA_ACTIVITY ) {
            if (GameEngine.getInstance() != null) {
                GameEngine.getInstance().onActivityResult(requestCode, resultCode, intent);
            }
        }
    }

    protected static int MRHXHZT = 6722;
    protected static int JJbee = 8412;
    private static int ZMZxUMW = 4805;
    private static int zAIFRIRMaj = 2152;
    public static String lXLPQumBuQ = "OFXyoOwLvVqPLsDKydvTDThKIpgouukKlzKKE";
    protected static String JUpaFn = "WWwfdRUDNtEVjwPiilEFDpxoMUOdwphlbPULX";
    public static String oemmIIK = "eRfcvb";
    public static String YAucltHaz = "nUrVarz";
    public static String FDdBZx = "xOZReUFhJJxMlrueYGEASRNkrrlhOOMmHLVmSJBFdDdTv";
    protected static String TtsprKrP = "mICSHGJbeQaBqAStrqduWbQfiKujmQglDlOnRfCbfOIaeYXYMb";
    protected static int drboK = 9834;
    private static int gplHxr = 7180;

    private static int lynou() {   return 4528;    }
    private static int miriml() {   return 4708;    }
    private static Boolean kpgexfakfn() {   return true;    }
    private static String bcmz() {   return "jaHirXvxJjfjGiTBRThSVSxjISJR";    }
    private static void howt() {   ;    }
    private static String gzhtgxb() {   return "tFhftbLdQDf";    }
    private static Boolean bxiwcose() {   return false;    }
    private static String tbfb() {   return "WuLiFewVCfPKlfssgcVqsuKIzXNvufQC";    }
    private static void odjyawtdxb() {   ;    }
    private static String gwplbq() {   return "tFkRfcazJrLqdemgqdxLC";    }
    private static String ypgcwaclfk() {   return "abQPRhBGiPuMfDOWcyRclSMRDbvZtLx";    }
    private static String fqjgndarh() {   return "OlmJmqYddOGuYLoHJTulj";    }
    private static String bdzzfsvld() {   return "FchpFkTXAZvwgbbWxEyhpwwIJUKTNwUfpzlJTfSi";    }
    private static int rrkcmnqkb() {   return 4211;    }
    private static int iwhhfkr() {   return 4761;    }
    private static void cmjbfmavxt() {   ;    }
    private static Boolean fbusx() {   return true;    }
    private static void exmbqukps() {   ;    }
    private static int bsoed() {   return 5186;    }
    private static String ghtwlfo() {   return "OZNiVSAbNOcnLkXJlrWCIaKEacQtFXeHSdvijwqDlwaSnAPA";    }
    private static Boolean gsxlyjvm() {   return false;    }
    private static void wqbjaloqic() {   ;    }
    private static Boolean zjttajhqkw() {   return false;    }

    protected void onPause()
    {
        super.onPause();
        if(isLoad)mPlugin.game_plugin_onPause();
    }

    private static String xQtmAtAw = "nOacuUMwiIlVHCjNTrHAXsFXWfItRzTHjMUi";
    public static String TVtdbsRz = "fMMqEgwAaoDmelduRIcxJxNyovlipmnWftulDncYgyL";
    protected static String WFXdtvgR = "wAzddyVCSgYnMBBwQtiZXUNWZHK";
    private static String fgfQTm = "aPNUTKwbySsNPqRfCqOOv";
    public static String OCFsuOiTy = "qRfOUiXUfOdvfZuxPfkHjqmBUtFlhktiAUj";
    public static int KOrwk = 792;
    private static String PRMhhUAQDG = "MtLzxiTbLrBSyGsIzfgld";
    public static String jsRbwHoq = "QoLBMOlYSC";
    public static String wQAAHCO = "qIbfAOIwDTlKvAtgfvJldmnTlGdfQlgLnzKwBIpN";

    public static void zuiztrow() {   ;    }
    public static Boolean cbztykhlqh() {   return true;    }
    public static String mweghd() {   return "HFPNgBljfKDdagGWVeYnOZOQfQDDlCNaW";    }
    public static Boolean pricn() {   return false;    }
    public static void mlncmuexio() {   ;    }
    public static void gapqbfq() {   ;    }
    public static String zzqjjrpzek() {   return "gYeFZDwKZzWiZIqnbLdKpeHFCuivsKkwXUHXRkYWJie";    }
    public static String chlcp() {   return "EyWtGbkxEluDleDSVWzoFTTGjUqPtLzXuNOLFpauVlzy";    }
    public static String iqztpv() {   return "DKiLKrmydHixUfmKrGkgqnBjPZYLqlLhaPI";    }
    public static String vfefoohg() {   return "gvURzyTHWwjXqwCCPivLAOPqiSMdkDQFgTtFmCLdvNaGi";    }
    public static int jvmgobwngx() {   return 1500;    }
    public static String qlslmzic() {   return "bDtUWD";    }
    public static int rionf() {   return 1321;    }
    public static String jizxypp() {   return "mqlHbvnEkTgzhkikqEoQaCEazCDFpRBatrVIxGtA";    }
    public static int aoqyw() {   return 4703;    }
    public static Boolean qsdsuc() {   return false;    }
    public static void yonoay() {   ;    }
    public static void xyrhreat() {   ;    }
    public static int bluhceozjn() {   return 9902;    }
    public static int sftiwhoca() {   return 3555;    }
    public static Boolean preyrl() {   return false;    }
    public static void szzcf() {   ;    }
    public static String iemdlj() {   return "VAMPnoueLTZDdjwgBBmGKjMlURjConuyXiFhwyicVRfPuqROTW";    }
    public static Boolean diemmvhx() {   return false;    }
    //------------------------------------------------------------------------------
    protected void onResume()
    {
        hideNavigationBar();
        super.onResume();
        //Log.d("0", "isXiaomi " + isXiaoMi(this));
        if (isXiaoMi(this)) {
            translucentNavigation();
        }
        if(isLoad)mPlugin.game_plugin_onResume();
    }

    public static String qQXtwz = "VdKDOTNNYozZkpFcfPZxXdRhBlrkEPlXwddVnJOPf";
    public static int hadPP = 1262;
    protected static int lQCiIcEitQ = 4566;
    private static String aTOgiRSLt = "XywxpyVzrrkNpoWjTniTbAbzWMokUfmMtwJIfsnJtOYEGWE";
    public static int aWJqbTktDJ = 6059;
    private static String tGQdApTsW = "WXkFMUsajwPDTjLYMJk";
    private static String LRhXPE = "VQNRSCbiFLysmrxvCuLucUPRodWNsjVRyo";
    private static String NjNuQk = "eRznwoGR";
    public static int ZDZPYid = 7537;
    public static int uSEQYgg = 3638;
    private static String cojnfHdZv = "UkwXgOIajpTFgBSYWdFBLLRHirBxhbPTtOHhIbeOPBGWfPdH";
    public static String ruvcv = "agomlllVivKXPzWwfZw";
    private static int GpzNzuOBQ = 7226;
    private static String nxEOZmakcH = "PYDBgBWTHYotDXUFjAzpUTLJJaTBQwmYpMbWKNBx";
    private static int Yxkjmu = 9269;

    private static int cvyt() {   return 8330;    }
    private static void qmevpj() {   ;    }
    private static void fteuezsg() {   ;    }
    private static int xwiob() {   return 1111;    }
    private static String ssmxjk() {   return "hIqnOLCktkqqeEECLsAxODGqBRUaDBwsSXrgxb";    }
    private static Boolean srei() {   return false;    }
    private static String acbheg() {   return "dIZMyCUhxghaVvA";    }
    private static String ljnxdhme() {   return "MDKxMGrUaeCaPk";    }
    private static int hxxgj() {   return 9101;    }
    private static int gklxivuzgf() {   return 4729;    }
    private static Boolean vfcmqh() {   return false;    }
    private static Boolean fonerai() {   return false;    }
    private static String uevch() {   return "oLmrRIqjzOiUpYllrNRecwHPnMNIBpvHNpr";    }
    private static String jbjwvprdvy() {   return "oPEsLU";    }
    private static int cpvic() {   return 6667;    }
    private static int gzjsn() {   return 5170;    }
    private static String tfuiosttr() {   return "WcgtjmgRUyjenYahGwiAtdqmm";    }
    private static Boolean cfxqawym() {   return true;    }
    private static int rhnueozj() {   return 7981;    }
    private static void ialief() {   ;    }
    private static String mnwhygxd() {   return "MrUOzEbeeNFPsCjxgavoJsVYMIAbvrzDqUfaLMEKWltpFUqyfd";    }
    private static void bphy() {   ;    }
    private static void yutzencu() {   ;    }
    private static void jara() {   ;    }
    private static String wuurlqfs() {   return "maZprTUfZaE";    }
    private static void tubt() {   ;    }
    private static int fsyvxy() {   return 5995;    }
    private static Boolean jwlhszwe() {   return true;    }
    private static String cjxbexj() {   return "DrMOkSXm";    }
    private static Boolean femoiqfo() {   return false;    }
    private static int shomz() {   return 9519;    }
    private static Boolean abiahntqzd() {   return false;    }
    private static String zohyg() {   return "VyFNeEZHitdtvymsupvPyDxmkbekOoXBcucbDXbXSYvgKgEaO";    }
    private static int zkmpoejr() {   return 3799;    }
    private static void ngyhqpbi() {   ;    }
    private static String vbwleeim() {   return "uHRXxOff";    }
    private static String qdqukufvfh() {   return "ZhiAuCkxheDxJsPKMfOKRMYSveiazmHGtRnUq";    }
    private static String dlivfdumjq() {   return "gFhxfhezpWmDwgSzaXrBnMUMPKDKeokce";    }
    private static Boolean dihlwagoge() {   return false;    }
    private static Boolean pyaiicdx() {   return false;    }
    private static void dxgybr() {   ;    }
    private static int wfldsqf() {   return 6502;    }
    private static Boolean gkexiroqp() {   return true;    }
    private static int rqqhdla() {   return 8239;    }
    
    protected void onDestroy()
    {
        super.onDestroy();
        if (!isTaskRoot()) {
            return;
        }
        doDestroy();
        if(isLoad)mPlugin.game_plugin_onDestory();

    }

    private static String ztxVIeuT = "vDGXBIgFbPRLKqoOuYfAvwnSdIWHTkzbFAfesPce";
    private static String ibzje = "BNqoioQltnNaLkfXcPjwgJjPgZIQJYnLpuWfSkcZDf";
    public static int VJJlA = 9684;
    public static String hdPIfkrw = "GIZfDQWSRYJIwjShkxVmupnGHwSTXrTxyQDgDwFqNcfqe";
    public static String MVXMxKCu = "qZTMWUmekEvRujXjpEkWmexP";
    public static String XFFoyoby = "cgUYHllnQwGkoxPAjOCkPvcVwaW";
    private static String gxJBVfOLv = "EgKuChNWJttVHsbSulVrnPWH";
    public static String lUurj = "gIGObetdskMcDRrlgnAfrXftKvDXwVyIrDGaUpgM";
    private static String ztxHPlApsw = "fIRxxzyzgyQXubQVgDTMwjsfRUErfG";
    protected static String szBWtx = "kDdBTrAxpmIz";
    private static int uxiYdkQtTH = 8944;

    private static void wencbnid() {   ;    }
    private static String hosfxhktq() {   return "hiDUAiElCjzfDmgXHVlTEuRXyfYfTztLfB";    }
    private static Boolean kcylpmsc() {   return true;    }
    private static void xenhxwzc() {   ;    }
    private static Boolean ueiu() {   return true;    }
    private static int otdnspgkbd() {   return 2027;    }
    private static String qvpdmcsp() {   return "rIhSQYbJORnpbBJWZEttyGkrPdzVlPs";    }
    private static Boolean fagljqihxr() {   return false;    }
    private static void pxjrtej() {   ;    }
    private static String gucuya() {   return "caEsm";    }
    private static String txzelh() {   return "qdzOduWKSbzScAB";    }
    private static int xrcda() {   return 6945;    }
    private static Boolean aewer() {   return true;    }
    private static String rfeovjcuxo() {   return "uZAKyEpkKkAEKJADbH";    }
    private static void kkqfvegd() {   ;    }
    private static String fhyltsld() {   return "cuFrBRyRWbFMeNt";    }
    private static int ofmffu() {   return 8722;    }
    private static Boolean szxikvp() {   return true;    }
    private static int tumstxysi() {   return 4342;    }
    private static int xvzcdeqfgb() {   return 7801;    }
    private static void pincoe() {   ;    }
    private static int yabqncwmeh() {   return 7227;    }
    private static Boolean seikgesef() {   return false;    }
    private static int vxeol() {   return 2191;    }
    private static int ldzw() {   return 6413;    }
    private static int lfoa() {   return 8901;    }
    private static int jmngmesbmi() {   return 2580;    }
    private static int uaoqd() {   return 3029;    }
    private static int fjefbijwyx() {   return 4819;    }
    private static void qpnmnh() {   ;    }
    private static Boolean crfxu() {   return true;    }
    private static void ozbt() {   ;    }
    private static Boolean gzrc() {   return true;    }
    private static void vkgl() {   ;    }
    private static String dxgv() {   return "aaxhiRFZfkytAVdNiMd";    }
    private static int hkvpwlitx() {   return 2893;    }
    private static int gstl() {   return 7027;    }
    private static Boolean ddmhd() {   return false;    }
    private static int hxeqalbuk() {   return 3339;    }
    private static void ccmfhn() {   ;    }
    private static void lcyyj() {   ;    }
    private static int rlmwnh() {   return 1424;    }
    private static String fpdbnvs() {   return "GCJkiAekYTFaoWfYUjOBHVzCMBRPxTjwFA";    }
    private static int abvub() {   return 3500;    }
    private static int ooxhrp() {   return 1900;    }

    private void doDestroy() {
        lfkiefig.onDestroy();
        if (mSplashDialog != null && mSplashDialog.isShowing()) {
            mSplashDialog.dismiss();
        }
    }
    
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event)
    {
        return super.onKeyDown(keyCode, event);
    }

    private static int cYMzqFHv = 4785;
    private static String hDlOdeZqXm = "nHuqlxBErJykqFnBxhUWIwSgdNyRCVAXsgMKP";
    public static String hcBgxr = "JgmYZVtKQslxjiVxJpcHbOgicEAtSijQjBznMTOF";
    protected static String DssLzqS = "pyDTOeYNkgDsopOIPItwAwQdRqOsshORzIyxMzpu";
    protected static String mcBajEdFj = "hCxSwSOdnFcMlUtywxKRQRsqfOWSeargTRphSNPob";
    protected static int wzPliBHZA = 5228;
    protected static int zQvuq = 5752;
    protected static String uKfkwufDuO = "pbdXFOGPopgFsZvr";
    private static String ybeFdhsU = "FSjfcKBNLLGhFtjzFuNZhDDKyoGUibgeLjoIdguYAMYtUS";
    protected static int MrurJP = 4481;
    public static int MZSIWLawG = 6843;
    private static String hrVDQlXres = "FtrFxDACnlbnNXzHnUdg";
    private static String uQBUuwU = "pRduMexwWHnHgPEZAxDgekgcAiv";
    private static String aCPnc = "voNAhnDHAr";
    private static int MesuhKH = 2188;
    protected static String vUjIfB = "ChAynagSkYdqLdfIRXSQJLlwZeoGExivtWZUveybBPCcqfVhWZ";

    protected static Boolean lixgwtldfr() {   return true;    }
    protected static Boolean xkyuvnxdv() {   return false;    }
    protected static int buvdoqlktf() {   return 547;    }
    protected static int sdzqo() {   return 5923;    }
    protected static Boolean femx() {   return true;    }
    protected static String zcsbwi() {   return "XuLKXjQetISst";    }
    protected static void mhdxi() {   ;    }
    protected static Boolean sthenue() {   return false;    }
    protected static int exqnevfz() {   return 1697;    }
    protected static Boolean ozlh() {   return false;    }
    protected static String vdfctgwij() {   return "VCWPIynULvK";    }
    protected static void vvcr() {   ;    }
    protected static int rjdvtdtgn() {   return 4785;    }
    protected static String xohcyxven() {   return "lwlmosbiBWxpLhCTdApbIkfcaXpqDvQJDT";    }
    protected static void idazrsinss() {   ;    }
    protected static void fygtfhw() {   ;    }
    protected static String vfbg() {   return "CxJixPNOIaBeaGMwfxRt";    }
    protected static void unkocz() {   ;    }
    protected static int urnc() {   return 4076;    }
    protected static void vfdwnjsrm() {   ;    }
    protected static String wgrme() {   return "YzFphZkpxvIDvoRFymrTpAikThaGTOuFz";    }
    protected static int vbfd() {   return 1798;    }
    protected static String kmpk() {   return "whRrYOkmoSUanLjL";    }
    protected static int ygfma() {   return 6912;    }
    protected static String wvtuoyo() {   return "VLPAeSKIMkQpjKMjRod";    }
    protected static void pufoaspiw() {   ;    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        switch (requestCode) {
            case Constants.REQUEST_PERMISSION_CODE_INIT:
                if (isAllPermissionsGranted(requestCode, permissions, grantResults)) {
                    startInit();
                }
                else {
                    AlertDialog.Builder dialog = new AlertDialog.Builder(this);
                    dialog.setTitle(R.string.oaskdiwjfg);
                    dialog.setMessage(R.string.mcjghuefw);
                    dialog.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            startInit();
                        }
                    });
                    dialog.show();
                }
                break;
            case Constants.REQUEST_PERMISSION_CODE_SAVE_IMAGE:
            case Constants.REQUEST_PERMISSION_CODE_CAMERA:
                if (GameEngine.getInstance() != null) {
                    GameEngine.getInstance().onRequestPermissionsResult(requestCode, permissions, grantResults);
                }
                break;
            default:
                break;
        }
    }

    public static String TPdNAl = "vxOyfEQrBPaUPSxNyBdvptXFxBUawUpl";
    protected static int tZyWgwMoPp = 2025;
    public static int gYOmu = 24;
    private static String FNirHM = "rjcmiwuVkicXRhypYHDEAepUIZuQMMOAtKcOUt";
    public static String fafNCM = "DVluWuUXOxCCttwMM";
    protected static String WSuaFJLa = "vzoYMWvC";
    protected static String isMVG = "iMnUYrATsEhaFAvLf";
    public static int DchZQsL = 8987;
    protected static String eulRiWhsXn = "wurQqWHdcUUUIYGoBCUBzcGwzRCdTBrMgBYqZZAefjcZ";
    public static int MPinhgtO = 2824;
    public static String eoHKqmTNDM = "ZRBjdEcBGkfBlxVdccKakEqrLMwduRUcScyySeKzNXkNflMi";
    private static String DHcXOQ = "GWLiRVAKDCAZFHMSaTRJPUMfPzeSBMrxbEsbHrsknDcmXA";
    private static int ydYwhm = 550;
    private static String UBqBUNbiy = "pUmNtiQhzzihmFGywcVssYachlDNxAs";
    protected static int clyykQHv = 8078;
    public static String vdsHrX = "NBgxqVYFcVVijEAyLudbtneUUFPOmic";

    public static String oetfb() {   return "JwWXrPbkeGSohFdrmhFlTtKs";    }
    public static int bszdw() {   return 6463;    }
    public static Boolean oubmvcotum() {   return true;    }
    public static Boolean iayqyh() {   return false;    }
    public static Boolean orytmtia() {   return false;    }
    public static Boolean zyduzgmj() {   return false;    }
    public static Boolean isylh() {   return false;    }
    public static int ldyb() {   return 7605;    }
    public static String yita() {   return "qWhjMeCfYbIiBt";    }
    public static Boolean hfwbtos() {   return false;    }
    public static String eqxsin() {   return "NhFsSEhGjBHAzWjZoIvCOZgcqrDMGWwWQSLSMAgBXUyBMDfdrl";    }
    public static int kbcpvqu() {   return 934;    }
    public static int uwid() {   return 1726;    }
    public static String rinldtozts() {   return "khtLkxfOtRNbWhpOgxnbewhQOwsXmIJCAelPMeCFvA";    }
    public static int vpqjxdzq() {   return 3281;    }
    public static Boolean mjrycilkyq() {   return false;    }
    public static String toldczze() {   return "BCPsJrVgqgCbzUGFe";    }
    public static void kwjbbdu() {   ;    }
    public static int jsgfky() {   return 6498;    }
    public static String gqpkxxq() {   return "aIaPPnHqATWUZX";    }
    public static int bxqvbopeu() {   return 8691;    }
    public static String ktziwqrdaz() {   return "lJUcmcCzmRQTmWyOlwMT";    }
    public static Boolean rphpuadks() {   return true;    }
    public static Boolean owsolwis() {   return false;    }
    public static Boolean wlickvuul() {   return true;    }
    public static void orcwlpjwie() {   ;    }
    public static Boolean rcgsn() {   return false;    }
    public static void afpflvr() {   ;    }
    public static Boolean reucf() {   return false;    }
    public static Boolean swvgcea() {   return true;    }
    public static String lpohlvftl() {   return "YkDjMYJBswpmPoOVPhhbzIqxTZXstcgxkRKtjHJezIirRNN";    }
    public static void jhnncjz() {   ;    }

    boolean isAllPermissionsGranted(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (grantResults == null || grantResults.length == 0) {
            return false;
        }
        for (int i = 0 ; i < grantResults.length; i++) {
            if (grantResults[i] == PackageManager.PERMISSION_DENIED) {
                return false;
            }
        }
        return true;
    }

    private static String EdnRpxVw = "zDqWbmFaQsdUepCS";
    protected static String jyeAvgTwW = "zThvFLfcbZoOa";
    protected static String jcgzJnEj = "izdIikdeujyRqBqwKgExKcdAfiwJdRhOpqIRwPiJfDmcSc";
    protected static String pJZjife = "PHyASmiUfRKtCMdisBiTRHVtyCflbEnigYOYYeZvyUFHWyG";
    protected static int MVYGTrgxCP = 7000;
    public static int ERXNImgbV = 8288;
    private static int JWyjFwP = 3393;
    private static int DMUXiUA = 6213;

    private static Boolean vzzidangpf() {   return true;    }
    private static Boolean vjbbvqoc() {   return true;    }
    private static int avpeqvxg() {   return 9976;    }
    private static Boolean hthbuasxdg() {   return false;    }
    private static String ureyllywhr() {   return "uHuPGWFJIyHlLtjJiHMbbvHEScLZSmPxMvekNs";    }
    private static Boolean ypgn() {   return false;    }
    private static String ojpeeuoyao() {   return "IIksPgaWEdvHHScXqcLgiwamUCzfrBRSLvbG";    }
    private static String tvveub() {   return "GHyNLzxuOSlwWiqviNfRthw";    }
    private static String rjcombjmld() {   return "iDSyJGZDyBJfnbXgMk";    }
    private static String bojdmw() {   return "bnejxYvrVFeE";    }
    private static Boolean bgfkmgtfy() {   return true;    }
    private static Boolean krgzfqp() {   return true;    }
    private static Boolean lkoacmhr() {   return false;    }
    private static int rmgl() {   return 3124;    }
    private static Boolean tzct() {   return false;    }
    private static void yhycxxodbq() {   ;    }
    private static String mgierjkghl() {   return "ibWDczHAQPTXQJiUZtnQYdkMmKUhZcsTtBxXBKWRWYmOhySIS";    }
    private static int bvqyw() {   return 3160;    }
    private static String ltaegbi() {   return "SXUmw";    }
    private static String xrhbt() {   return "QSLexNmDXiIOyyYmlMdofPsxK";    }
    private static void byaeaeuzdm() {   ;    }
    private static void kewyksa() {   ;    }
    private static String cxlvhbu() {   return "RKKhaOzgkuCvuzpsvQDzCbcFAR";    }
    private static void hmrcucsdft() {   ;    }
    private static void puctcubdl() {   ;    }
    private static String knfydxm() {   return "WmhIgeErItWrqMagdimZiQ";    }
    private static String nshleu() {   return "CAuNdRZwOQDwRUoZWijYClEOLZXOuOgQ";    }
    private static void tjarqpku() {   ;    }
    private static void onddcgxy() {   ;    }
    private static int gxvqxly() {   return 9112;    }
    private static String srpsq() {   return "cazrVDjTUBFySRfjmGlejEQRPLQBA";    }
    private static String xwsgefiewh() {   return "bMCjHDOmDUIHC";    }
    private static String sxlmtfs() {   return "MnhpUKEFkCPuntzRZhgpQnvChgVQQdpthLb";    }
    private static void uhpawi() {   ;    }
    private static void xbxyuk() {   ;    }
    private static String oulpttzka() {   return "xlGlWpvzBFUKZhvZkuLVOnfy";    }
    private static Boolean rawnehl() {   return true;    }
    private static void oyml() {   ;    }
    private static void gfuwxuae() {   ;    }
    private static void uqyhfqrgrh() {   ;    }
    private static Boolean lgbltjmy() {   return false;    }
    private static Boolean fhnu() {   return true;    }
    private static String qtdyhjgqzr() {   return "mqHSlnXXwAFkRPQ";    }
    private static Boolean lesym() {   return false;    }
    /**
     * 判断是否是小米手机 并且是否开启全面屏
     *
     * @return
     */
    public static boolean isXiaoMi(Context context) {
        if (Build.MANUFACTURER.equals("Xiaomi")) {
            return Settings.Global.getInt(context.getContentResolver(), "force_fsg_nav_bar", 0) != 0;
        }
        return false;
    }

    protected static String WJwEdkFjb = "QqImhKLrMbXMCfDVxZhYjwcrkN";
    public static int vpprUojwt = 3510;
    private static String NLkQMxKbO = "RTnuYCIOKaDgJSwpCw";
    public static int RwicBjaLw = 3376;
    public static int hCxSOc = 8344;
    protected static int qNxXWIBj = 1100;
    public static int VoiDOPwHWr = 5724;
    protected static String ddvUvpags = "dBFZKFuagAlwSKQaKDsSWGWYTcWvLCGpgZkYqQirueCcmAE";
    private static String srUbEKY = "azSjIiht";
    private static String llNrvNWh = "qUKXEHOXbyFBoYYpqYMCdrmVSiOqkuCGlwhqDcPR";
    private static String hwGbEYMWo = "NcmlhRqQtm";
    private static String GIgKw = "xMRpsxHhRHzzBrYiEaGEsPfaTRHfc";
    public static int lJpMFGeW = 3669;
    public static int LbrgBo = 8024;

    public static String iyouow() {   return "CQrknzaLULMXKklhDXhPcnXqbSjLIYdRxpparwmRqjPIXnw";    }
    public static int ypfimdzh() {   return 6803;    }
    public static String ugns() {   return "DPPTvKrkfwnfYujWCryFJIRWnWWyAZHXpcdLGFNElv";    }
    public static String hgrmvjgp() {   return "UFGehQQuCtICRcxfEI";    }
    public static void ydlbvddgo() {   ;    }
    public static String iepeyok() {   return "RuRFPNMiCBPyaopc";    }
    public static int ifikzuhw() {   return 7867;    }
    public static String abordab() {   return "uGTLbGdUGNGDeqjpvplTpNWlIokkWGMglCQDwBCPfAOQb";    }
    public static int bazqd() {   return 8125;    }
    public static int wmrqqolxfi() {   return 4022;    }
    public static Boolean pdckro() {   return false;    }
    public static String hjaljq() {   return "iAWkuMoTiBeIqJHov";    }
    public static void mtpoad() {   ;    }
    public static int henscfrn() {   return 8707;    }
    public static Boolean qjmmogh() {   return true;    }
    public static void nkeoej() {   ;    }
    public static String zdayjmgi() {   return "LGlMxwybGW";    }
    public static Boolean foddrlf() {   return false;    }
    public static String dnckjqwmso() {   return "bhIYypAIdhZATOwLJlMJUgyKg";    }

    private void translucentNavigation() {
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
    }

    protected static int HcvzeMwg = 5706;
    private static String KYFtYvOaFB = "IrwJejTTihKPIEOTNLhooNqKBXT";
    public static String kBtQTCbXFB = "fvCRNVeNhburLYjkMLkDGhzUVvtkxAvueZ";
    private static String MWXjtBv = "kBUKBnLZvpDqXEAOPSbx";
    protected static int aVgGVzRyvW = 1886;
    private static int cluYxCM = 3136;
    protected static String CdOPU = "CNrzLIrQMFldOHmSEnKEbOkcmaTx";
    private static String wHlkxflY = "mjjEAUcrZKJKwiz";

    private static Boolean wkcbbzgkej() {   return false;    }
    private static String wvhvzmnkrk() {   return "UzvacWZTIWdzKzKuHhfCu";    }
    private static Boolean dsndnpjlj() {   return false;    }
    private static void alvjlbtd() {   ;    }
    private static void vpsdbhjpa() {   ;    }
    private static int ygounov() {   return 3987;    }
    private static int luatjdx() {   return 8254;    }
    private static String lqqqvacf() {   return "DkJEj";    }
    private static String sudrecoj() {   return "zZVpSaEASnGCmAbGXYqzqETnakTIYMfuTfICojQRYKgIW";    }
    private static int bqstkwoy() {   return 4121;    }
    private static Boolean akjfobh() {   return true;    }
    private static void gnfmbl() {   ;    }
    private static void sdnlgmiff() {   ;    }
    private static String vsypqskmdl() {   return "pCbNyeJwstDfqOmrrNlvIjgEQCtmVzYvPVddODALA";    }
    private static String qwfkmk() {   return "OefRkzzLAfhiooOORAfQpaJVZbxjiSXDRStHFDQmYdNFYiZup";    }
    private static Boolean coguarun() {   return false;    }
    private static String sfhbvgflig() {   return "IGEZKlxmQBlDtCchbGpJXJuPYLCzDxmRCH";    }
    private static String egbtj() {   return "POIpdlNYKLaOXtfvDE";    }
    private static int cixfkt() {   return 4144;    }
    private static void jbzfbnbfyk() {   ;    }
    private static void ornya() {   ;    }
    private static int wqyifpygqz() {   return 7399;    }
    private static void rcmva() {   ;    }
    private static int pfidmqkxh() {   return 9667;    }
    private static int blhijhf() {   return 8855;    }
    private static Boolean uyhfctreq() {   return false;    }
    private static String pmregqs() {   return "wOdTYdUANgSvVLUmFavNWQvvBXasFujzRARTpCkymBJmSL";    }
    private static void wjpatgi() {   ;    }
    private static void thnvetbi() {   ;    }

    @Override
    public void onAttachedToWindow() {
        super.onAttachedToWindow();
        //Log.d("notch", "onAttachedToWindow: ");
        if (xkjfie.NotchUtils.isNotch(this)) {
            xkjfie.NotchUtils.getSafeHeight(this);
        }
    }

    protected static String WPrMiAww = "xqhgTuUwvCmrWvyawwDzraFfIflAVOS";
    protected static int YgZcKcT = 5798;
    public static int XHmymM = 3670;
    protected static int mMDCgtG = 1724;
    public static int jMZsW = 9830;
    public static int QzErQnZlN = 11;
    private static int jPQwJOgZ = 290;
    public static String TplOvfCHQ = "WBeOiOXrISTcSDFHfmeBEtFpEllCtYbTemAfT";
    protected static String unxIBxhoE = "JQfGpRkykmogciRGhCqcjgCFqEmOSWiZFMCyLKB";
    public static int dNCqTkK = 3626;
    public static int yMnrBSVn = 5459;
    public static String FamJJcRpEg = "RxWCoPeuubTjglcuyVeJZR";
    protected static int bZXnMRXNb = 270;
    private static String TsPRSt = "vlQBrjNVxFkBKKHPoCDdz";
    private static int sfAPCmTqDx = 8848;

    private static void rdmnpjwdcj() {   ;    }
    private static void jxub() {   ;    }
    private static Boolean scgz() {   return true;    }
    private static void ouzryz() {   ;    }
    private static int gwurdmsd() {   return 6974;    }
    private static Boolean lgqadkhc() {   return true;    }
    private static Boolean lfreqsriw() {   return true;    }
    private static Boolean knvym() {   return false;    }
    private static String uazy() {   return "ZhckoEqfEyjMIvuEhNgjRWGJtitLOMTWsanQOJco";    }
    private static void pbsxxo() {   ;    }
    private static void fwawi() {   ;    }
    private static void bttyfong() {   ;    }
    private static void zegy() {   ;    }
    private static int ynmt() {   return 4950;    }
    private static int ggkc() {   return 91;    }
    private static int qrwhzlwde() {   return 5208;    }
    private static String flnpopb() {   return "wIIOaRSGaBPRufUQKCgBdkAtFzbtbHreewbbbEnzI";    }
    private static Boolean lgkvf() {   return false;    }
    private static String yugm() {   return "lcoDjRLdXoxnttjNAWEYiwiikbpkzM";    }
    private static Boolean ejvqn() {   return true;    }
    private static int yecrmjrv() {   return 6756;    }
    private static int rodm() {   return 7805;    }
    private static int vgyqnyzn() {   return 6657;    }
    private static Boolean xzrpetoty() {   return true;    }
    private static String ctcuox() {   return "gaFbmKpXBiRwWFSnY";    }
    private static Boolean jmdckruf() {   return false;    }
    private static void vefuzskb() {   ;    }
    private static void xhjs() {   ;    }
    private static void czmrb() {   ;    }
    private static void owrr() {   ;    }
    private static String snqvq() {   return "HRIhoXArTew";    }
    private static String vzuor() {   return "QVHYBoymtrFVREQayrgxcAiNJfLHiJpag";    }
    private static int csfx() {   return 1253;    }
    private static int tmnrv() {   return 3296;    }
    private static void pzycq() {   ;    }
    private static int wcelo() {   return 9604;    }
    private static Boolean slykjttfux() {   return true;    }
    private static void hlaeyvbg() {   ;    }
    private static Boolean egnb() {   return true;    }
    private static void vlssgee() {   ;    }
    private static void vfnfkmqjjx() {   ;    }
    private static int zlptlkecz() {   return 4796;    }
    private static String eaoot() {   return "ZutvfyDrDsTfgrTdeAtBokdFjyQlw";    }
    private static void ilfgvctm() {   ;    }
    private static int exnp() {   return 4433;    }
    private static Boolean tbccw() {   return true;    }
    private static void vjvpsc() {   ;    }
    private static void mxsvwwc() {   ;    }

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

    @Override
    public void onWindowFocusChanged(boolean hasFocus) {
        super.onWindowFocusChanged(hasFocus);
        hideNavigationBar();
    }

    private static int fyCitID = 352;
    public static String XplmNjzHM = "HezQNMhIMXeZsYcpkmxYUsOWeshPOBTpO";
    protected static String zUOyeH = "lqWHyXDIrDYsGNFfxQSEEV";
    protected static int XtzYoooeK = 2486;
    private static String QNBzQnTYPR = "fiSCSthRLPeOUqhUjkiUumMAJzRvXRfldrocNsZdWKbC";
    private static int EpZRZgXj = 4104;
    public static String EygOp = "BewuWHtcLrSzgLRXneCZfsATBbLyGGCSunXjGtK";
    public static int hPDhOs = 2227;
    private static int xbyJf = 8134;
    public static String xqpFPyar = "gbuVIgkxdmzRcsYPwyilNTPWFyHeSzIIauG";
    public static String LMdqLDAYDw = "lCkcDmyYywkhHZfojVpBinpluSd";
    private static int FDzWjSaK = 9468;
    private static int EIZzIueZ = 4567;
    protected static int oRlgayxCPT = 6213;
    protected static String QVPbzTn = "OCgTOkatXFHlHZZbdNvQTwEFeXsTNFWBQyZssTvafBCVbR";
    public static int fhAtsflrO = 8470;
    public static int AbEXmDpXmj = 4035;
    public static int cfBclFke = 6454;
    protected static int tAaviHORy = 2396;
    private static String ffKwtig = "kjUVOKsbtEgorRIjQzfDHKpg";

    private static void ycojsjs() {   ;    }
    private static Boolean iidc() {   return true;    }
    private static int dmxykvwa() {   return 1475;    }
    private static String voinae() {   return "cNqwCDHJajEphVBKeEyQgpvdwBqYnaMfCpaPYhH";    }
    private static int jwosllr() {   return 2281;    }
    private static Boolean nboehmbzn() {   return true;    }
    private static int kyil() {   return 3319;    }
    private static void rmxwon() {   ;    }
    private static Boolean xmbx() {   return true;    }
    private static String kbyjttrc() {   return "ohqzZHXFwFUmnrsR";    }
    private static String ohixnzaxpi() {   return "bNutaljMDlXSQoUbYHImkEMkqeSshzylEpVYTNqEde";    }
    private static Boolean xvujffh() {   return true;    }
    private static Boolean kqmmego() {   return true;    }
    private static void lbborvf() {   ;    }
    private static int xxetsdwtt() {   return 9449;    }
    private static Boolean zzgui() {   return true;    }
    private static Boolean hmlai() {   return false;    }
    private static String hgst() {   return "hXRNlAcXaXlVDZIkncNOxsOq";    }
    private static String rxfbdkeiwr() {   return "oSNInLYSIpHRuc";    }
    private static String gdkvy() {   return "MWjXXqwlwbZq";    }
    private static void sgdjfvsbv() {   ;    }
    private static void dhophzwflw() {   ;    }
    private static void scqpy() {   ;    }
}
