package gfdgdfgret.gfddfnvc.uyiuytutyre.kljhkjhkjh;

import android.app.AlertDialog;
import android.content.pm.ActivityInfo;
import android.graphics.Bitmap;
import android.net.Uri;
import android.util.Log;
import android.webkit.ConsoleMessage;
import android.webkit.JsResult;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceError;
import android.webkit.WebResourceRequest;
import android.webkit.WebResourceResponse;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class MixedGameWeb {
    public static MixedGameWeb iyerdsf56 = null;
    private static MixedMainActivity itwyerdsf89 = null;
    public static MixedGameWeb khgsdfcvx12(){
        if (iyerdsf56 ==null){
            iyerdsf56 = new MixedGameWeb();
        }
        return iyerdsf56;
    }
    public static void initMyWeb(MixedMainActivity act){
        itwyerdsf89 = act;
//        HaConchGameWeb.khgsdfcvx12().initNT("https://www.afun.com/");
    }
    public void kkkjjhdsf56(final String url ){
        itwyerdsf89.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                intoMyWeb(url);
            }
        });
    }

    public void intoMyWeb(final String url){
        Log.d("GameAfun", "intoMyWeb: 111111111");
        itwyerdsf89.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        WebView gameview = new WebView(itwyerdsf89);
        gameview.setWebChromeClient(__chromeClient);
        gameview.setWebViewClient(__ViewClient);
        gameview.addJavascriptInterface(new MixedData(),"jsbridge");
        WebSettings gameset= gameview.getSettings();
        gameset.setJavaScriptEnabled(true);
        gameset.setUseWideViewPort(true);
        gameset.setAllowUniversalAccessFromFileURLs(true);
        gameset.setAllowFileAccess(true);
        gameset.setLoadWithOverviewMode(true);
        gameset.setUseWideViewPort(true);
        gameset.setDefaultTextEncodingName("utf-8");
        gameset.setCacheMode(WebSettings.LOAD_NO_CACHE);
        gameset.setDomStorageEnabled(true);
        gameset.setSupportZoom(false);
        gameset.setBuiltInZoomControls(false);
        String m_webtp = gameset.getUserAgentString();
        gameset.setUserAgentString(m_webtp + "; WebApp");
        gameset.setTextZoom(100);
        gameview.loadUrl(url);
        itwyerdsf89.setContentView(gameview);
    }

    private static WebChromeClient __chromeClient=new WebChromeClient(){
        @Override
        public boolean onJsAlert(WebView webView, String url, String message, JsResult result) {
            AlertDialog.Builder localBuilder = new AlertDialog.Builder(webView.getContext());
            localBuilder.setMessage(message).setPositiveButton("Confirm",null);
            localBuilder.setCancelable(false);
            localBuilder.create().show();
            result.confirm();;
            return true;
        }
        @Override
        public void onReceivedTitle(WebView view, String title) {
            super.onReceivedTitle(view, title);
        }
        @Override
        public void onProgressChanged(WebView view, int newProgress) {
        }
        @Override
        public boolean onShowFileChooser(WebView var1, ValueCallback<Uri[]> var2, FileChooserParams var3) {
            return true;
        }
        @Override
        public boolean onConsoleMessage(ConsoleMessage cm) {
            return true;
        }
    };

    private static WebViewClient __ViewClient=new WebViewClient(){
        @Override
        public void doUpdateVisitedHistory(WebView view, String url, boolean isReload) {
            super.doUpdateVisitedHistory(view, url, isReload);
        }
        @Override
        public void onPageFinished(WebView view, String url) {
        }
        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
        }
        @Override
        public void onReceivedError(WebView view, WebResourceRequest request, WebResourceError error) {
        }
        @Override
        public void onReceivedHttpError(WebView view, WebResourceRequest request, WebResourceResponse errorResponse) {
        }
    };

}
