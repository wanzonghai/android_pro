# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in E:\developSoftware\Android\SDK/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Proguard Cocos2d-x-lite for release
-keep public class org.cocos2dx.** { *; }
-dontwarn org.cocos2dx.**

# Proguard Apache HTTP for release
-keep class org.apache.http.** { *; }
-dontwarn org.apache.http.**

# Proguard okhttp for release
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

-keep class okio.** { *; }
-dontwarn okio.**

# Proguard Android Webivew for release. you can comment if you are not using a webview
-keep public class android.net.http.SslError
-keep public class android.webkit.WebViewClient

-dontwarn android.webkit.WebView
-dontwarn android.net.http.SslError
-dontwarn android.webkit.WebViewClient

# keep anysdk for release. you can comment if you are not using anysdk
-keep public class com.anysdk.** { *; }
-dontwarn com.anysdk.**
# Keep AppsFlyer classes
-keep class com.appsflyer.** { *; }

# Keep AppsFlyer receiver and services
-keep class com.appsflyer.SingleInstallBroadcastReceiver { *; }
-keep class com.appsflyer.AppsFlyerConversionListener { *; }
-keep class com.appsflyer.AppsFlyerLibCore { *; }
-keep class com.appsflyer.internal.** { *; }

# Keep AppsFlyer JNI methods
-keepclassmembers class * {
    native <methods>;
}
#保留Facebook SDK的所有类和方法：
-keep class com.facebook. {
    *;
}
#保留Facebook SDK的接口：
-keep interface com.facebook. {
    *;
}
#保留Facebook SDK的回调接口：
-keep class com.facebook.FacebookCallback {
    *;
}
# 保留Android Support库中相关的类和方法
-keep class android.support.v4.app.FragmentActivity {
    *;
}
-keep class android.support.v7.app.AppCompatActivity {
    *;
}

# 保留Gson库相关的类和方法（如果使用了Gson来解析Facebook SDK返回的数据）
-keep class com.google.gson.** {
    *;
}
