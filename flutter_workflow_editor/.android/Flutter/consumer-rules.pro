# Consumer ProGuard rules for Flutter module
# These rules are applied to apps that consume this AAR

# Keep Flutter-related classes
-keep class io.flutter.** { *; }
-keep class * extends io.flutter.plugin.common.Plugin { *; }
-keep class * extends io.flutter.plugin.platform.PlatformView { *; }

# Keep R classes
-keep class **.R$* { *; }