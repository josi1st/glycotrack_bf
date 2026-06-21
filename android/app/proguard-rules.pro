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

# flutter_local_notifications (regles completes - WorkManager + AlarmManager)
-keep class androidx.work.** { *; }
-keepclassmembers class * extends androidx.work.Worker {
    public <init>(android.content.Context,androidx.work.WorkerParameters);
}
-keepclassmembers class * extends androidx.work.InputMerger {
    public <init>();
}
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context,androidx.work.WorkerParameters);
}
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-keepclassmembers class com.dexterous.flutterlocalnotifications.** { *; }

# flutter_secure_storage (Android Keystore / crypto)
-keep class androidx.security.crypto.** { *; }
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keepclassmembers class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn androidx.security.crypto.**

# Reflexion generale (evite que R8 supprime des methodes utilisees dynamiquement)
-keepattributes InnerClasses
-keepattributes EnclosingMethod
-keepclassmembers class * {
    public <init>(...);
}