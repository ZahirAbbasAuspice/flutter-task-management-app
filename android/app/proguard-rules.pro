-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-dontwarn com.dexterous.flutterlocalnotifications.**
