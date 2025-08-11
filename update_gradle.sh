#!/bin/zsh

# 1. Insert after line 75 in android/app/build.gradle
sed -i '75a\            proguardFiles getDefaultProguardFile('\''proguard-android.txt'\''), '\''proguard-rules.prop'\''' android/app/build.gradle

# 2. Replace line 26 in android/settings.gradle
sed -i '26s/.*/    id "com.android.application" version '\''8.4.2'\'' apply false/' android/settings.gradle

# 3. Create android/app/proguard-rules.prop with required ProGuard rules
cat <<EOL > android/app/proguard-rules.prop
## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-dontwarn io.flutter.embedding.**
-ignorewarnings
## Gson rules
# Gson uses generic type information stored in a class file when working with fields. Proguard
# removes such information by default, so configure it to keep all of it.
-keepattributes Signature

# For using GSON @Expose annotation
-keepattributes *Annotation*

# Gson specific classes
-dontwarn sun.misc.**
#-keep class com.google.gson.stream.** { *; }

# Prevent proguard from stripping interface information from TypeAdapter, TypeAdapterFactory,
# JsonSerializer, JsonDeserializer instances (so they can be used in @JsonAdapter)
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Prevent R8 from leaving Data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Retain generic signatures of TypeToken and its subclasses with R8 version 3.0 and higher.
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# Missing javax.annotation classes - suppress warnings
-dontwarn javax.annotation.Nullable
-dontwarn javax.annotation.concurrent.GuardedBy
EOL

echo "Changes applied."

git update-index --assume-unchanged android/app/build.gradle
git update-index --assume-unchanged android/settings.gradle

echo "Files marked as unchanged in git."
echo "Press any key to continue..."
read -k 1
