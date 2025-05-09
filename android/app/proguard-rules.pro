# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# AwesomeNotifications 플러그인을 위한 규칙
-keep class com.dexterous.** { *; }

# Google Play Core 관련 규칙
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }

# FirebaseMessaging 용 (추후 필요시 활성화)
# -keep class com.google.firebase.** { *; }

# 앱에서 사용하는 다른 라이브러리를 위한 규칙 추가 가능

# R8 전체 모드 경고 방지
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception 