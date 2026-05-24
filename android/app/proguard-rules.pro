# pixelvibe ProGuard Rules

# flutter_rust_bridge / media_kit native libs
-keep class io.flutter.** { *; }
-keep class com.media_kit.** { *; }
-keep class libmpv.** { *; }
-keep class mpv.** { *; }

# media_kit + media_kit_video
-keep class com.ryanheise.** { *; }
-keep class com.alexmercer.** { *; }
-dontwarn com.ryanheise.**
-dontwarn com.alexmercer.**

# drift (SQLite)
-keep class drift.** { *; }
-keep class * extends drift.** { *; }
-dontwarn net.sqlcipher.**

# nanohttpd
-keep class fi.iki.elonen.** { *; }
-dontwarn fi.iki.elonen.**

# smbj (SMB)
-keep class com.hierynomus.** { *; }
-keep class net.engio.** { *; }
-dontwarn com.hierynomus.**
-dontwarn net.engio.****

# Apache Commons Net (FTP)
-keep class org.apache.commons.net.** { *; }
-dontwarn org.apache.commons.net.**

# Kotlin coroutines
-keepnames class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# JSON (org.json shipped with Android)
-keep class org.json.** { *; }

# Flutter engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep R8 from stripping generic signatures
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep source file names and line numbers for crash reporting
-renamesourcefileattribute SourceFile
-keepattributes SourceFile, LineNumberTable
