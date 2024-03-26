# Key to sign the app
KEY_PATH = debug.keystore
KEY_NAME = androiddebugkey
KEY_PASS = android

# SDK tools version
SDK_VER   = 24
SDK       = 24.0.3

# Roots
SDK_ROOT  = ~/Android/Sdk
JAVA_HOME?= /usr/lib/jvm/java-1.11.0-openjdk-amd64

# Android framework, contains API
VEDBASE   = $(SDK_ROOT)/platforms/android-$(SDK_VER)/android.jar

# Tools
ADB       = $(SDK_ROOT)/platform-tools/adb
PM        = $(ADB) # same functionality on pc
MONKEY    = $(ADB) shell monkey
AAPT2     = $(SDK_ROOT)/build-tools/$(SDK)/aapt2
APKSIGNER = $(SDK_ROOT)/build-tools/$(SDK)/apksigner
D8        = $(SDK_ROOT)/build-tools/$(SDK)/d8
ZIPALIGN  = $(SDK_ROOT)/build-tools/$(SDK)/zipalign
JARSIGNER = $(JAVA_HOME)/bin/jarsigner
JAR       = $(JAVA_HOME)/bin/jar
JAVAC     = $(JAVA_HOME)/bin/javac

