# Hive
-keep class * extends com.hivedb.HiveObject { *; }
-keep class **.*Adapter { *; }
-keepclassmembers class * {
    @com.hivedb.HiveField <fields>;
}
-keep class com.example.glycotrack_bf.** { *; }
-keep class com.example.glycotrack_bf.models.** { *; }

# local_auth (biometrie)
-keep class androidx.biometric.** { *; }
-keep class io.flutter.plugins.localauth.** { *; }

# flutter_local_notifications
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }

# connectivity_plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Gson / JSON
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

# http / reseau
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# timezone
-keep class org.threeten.** { *; }
-dontwarn org.threeten.**

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Google Play Core (deferred components - non utilise par notre app)
-dontwarn com.google.android.play.core.**