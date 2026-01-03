# Add any Flutter-specific ProGuard rules here
# Keep classes and methods used by Flutter
-keep class io.flutter.** { *; }
-keep class com.example.** { *; }
-keep class * extends io.flutter.plugin.common.Plugin { *; }
-keep class * extends io.flutter.plugin.platform.PlatformView { *; }

# Keep native methods
-keepclasseswithmembers class * {
    native <methods>;
}

# Keep R classes
-keep class **.R$* { *; }

# Keep parcelable classes
-keep class * implements android.os.Parcelable { *; }