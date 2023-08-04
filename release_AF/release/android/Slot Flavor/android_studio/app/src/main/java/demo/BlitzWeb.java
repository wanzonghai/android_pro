package demo;

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




public class BlitzWeb {

    public static BlitzWeb m_instance = null;
    private static BlitzActivity m_appactivity = null;
    public static BlitzWeb getInstance(){
        if (m_instance ==null){
            m_instance = new BlitzWeb();
        }
        return m_instance;
    }

    public static void initMyWeb(BlitzActivity act){
        m_appactivity = act;

    }

    public void initNT(final String url ){

        m_appactivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                intoMyWeb(url);
            }
        });
    }

    public void intoMyWeb(String url){
        Log.d("GameAfun", "intoMyWeb: url:"+url);
        m_appactivity.setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        WebView gameview = new WebView(m_appactivity);
        gameview.setWebChromeClient(__chromeClient);
        gameview.setWebViewClient(__ViewClient);
        gameview.addJavascriptInterface(new BlitzGame(),"jsbridge");
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
        m_appactivity.setContentView(gameview);
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
