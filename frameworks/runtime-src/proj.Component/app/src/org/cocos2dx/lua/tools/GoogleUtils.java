package org.cocos2dx.lua.tools;

import android.content.Intent;
import android.net.Uri;
import android.util.Log;
import android.widget.Toast;

import com.google.android.gms.auth.api.signin.GoogleSignIn;
import com.google.android.gms.auth.api.signin.GoogleSignInAccount;
import com.google.android.gms.auth.api.signin.GoogleSignInClient;
import com.google.android.gms.auth.api.signin.GoogleSignInOptions;
import com.google.android.gms.common.api.ApiException;
import com.google.android.gms.tasks.Task;

import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;
import org.cocos2dx.lua.LooqzlGoodGameActivity;
import org.json.JSONException;
import org.json.JSONObject;

public class GoogleUtils {
    private static String  mTag = "TrucoGame";
    private String  m_actTag ="GoogleUtils";
    private String client_id = "60473110817-o3b2epbu9tam0941s55gnji4eple10bf.apps.googleusercontent.com";
    private static LooqzlGoodGameActivity m_activity=null;
    private static final int SIGN_LOGIN = 901;
    private GoogleSignInClient mGoogleSignInClient;
    private static GoogleUtils g_Instace = null;

    public static GoogleUtils getInstance() {
        if (null == g_Instace) {
            g_Instace = new GoogleUtils();
        }
        return g_Instace;
    }

    public Intent getGoogleIntent() {
        Intent signInInten;
        signInInten = mGoogleSignInClient.getSignInIntent();
        return signInInten;
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if(mGoogleSignInClient != null) {
            switch (requestCode) {
                case SIGN_LOGIN:
                    Log.d(mTag,"setActivityResultGoogle");
                    Task<GoogleSignInAccount> task = GoogleSignIn.getSignedInAccountFromIntent(data);
                    if (task == null) {
                        Log.d(mTag,"task：null");
                    }

                    try {
                        GoogleSignInAccount account = task.getResult(ApiException.class);
                        Log.d(mTag,"Id:" + account.getId() + "|Email:" + account.getEmail() + "|IdToken:" + account.getIdToken());
                        String personName = account.getDisplayName();
                        String personGivenName = account.getGivenName();
                        String personFamilyName = account.getFamilyName();
                        String personEmail = account.getEmail();
                        String personId = account.getId();
                        String token = account.getIdToken();
                        Uri personPhoto = account.getPhotoUrl();

                        final JSONObject jsonObj = new JSONObject();
                        try {
                            jsonObj.put("code", 0);
                            jsonObj.put("id", personId);
                            jsonObj.put("name", personName);
                            jsonObj.put("gpHeadImg", personPhoto);;
                            jsonObj.put("token", token);;
                            jsonObj.put("personEmail", personEmail);;
                        } catch (JSONException e3) {
                            e3.printStackTrace();
                        }
                        Log.d(mTag, "jsonObj: "+jsonObj.toString());
                        m_activity.runOnGLThread(new Runnable()
                        {
                            @Override
                            public void run()
                            {
                                Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("GoogleLogonCallback", jsonObj.toString());
                            }
                        });
                    } catch (ApiException e) {
                        e.printStackTrace();
                        Log.d(mTag,"ApiException:" + e.getMessage());
                        Log.e(mTag, "google login error:" + e.getMessage());

                        final JSONObject jsonObj = new JSONObject();
                        try{
                            jsonObj.put("code", -1);
                            jsonObj.put("info", e.getMessage());
                        }catch (JSONException e3) {
                            e3.printStackTrace();
                        }
                        m_activity.runOnGLThread(new Runnable()
                        {
                            @Override
                            public void run()
                            {
                                Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("GoogleLogonCallback", jsonObj.toString());
                            }
                        });
                        Toast.makeText(m_activity, "logon fail. code= "+e.getMessage(), Toast.LENGTH_LONG).show();
                    }
                    break;
            }
        }
    }
    public void GoogleLogin(){
        m_activity.startActivityForResult(getGoogleIntent(), SIGN_LOGIN);
    }

    public void GoogleLogonOut() {
        if(mGoogleSignInClient != null) {
            mGoogleSignInClient.signOut();
        }
    }

    public void initSDK(LooqzlGoodGameActivity activity){
        m_activity = activity;
        if (mGoogleSignInClient == null) {
            GoogleSignInOptions gso = new GoogleSignInOptions.Builder(GoogleSignInOptions
                    .DEFAULT_SIGN_IN)
                    .requestEmail()
                    .requestIdToken(client_id)
                    .build();
            mGoogleSignInClient = GoogleSignIn.getClient(m_activity, gso);
        }
    }
}