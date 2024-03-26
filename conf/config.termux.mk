# Key to sign the app
KEY_PATH = debug.keystore
KEY_NAME = androiddebugkey
KEY_PASS = android

# Please install dependencies first:
# apt install aapt2 apksigner d8 ecj openjdk-17

# Android framework, contains API
VEDBASE = /data/data/com.termux/files/usr/share/java/android-24.jar
AAPT2JAR = /data/data/com.termux/files/usr/share/aapt/android.jar

# Tools
PM        = sudo /system/bin/pm
MONKEY    = sudo /system/bin/monkey
AAPT2     = aapt2
APKSIGNER = apksigner
D8        = d8
ZIPALIGN  = zipalign
JARSIGNER = jarsigner
JAR       = jar
JAVAC     = javac

