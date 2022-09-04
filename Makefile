# Application information
NAME = Hello
CLASS= com.example.hello

include config.mk

# Android framework, DO NOT REMOVE!
VEDBASE = $(SDK_ROOT)/platforms/android-$(SDK_VER)/android.jar

# Tools
ADB       = $(SDK_ROOT)/platform-tools/adb
AAPT      = $(SDK_ROOT)/build-tools/$(SDK)/aapt
DX        = $(SDK_ROOT)/build-tools/$(SDK)/dx
ZIPALIGN  = $(SDK_ROOT)/build-tools/$(SDK)/zipalign
JAVAC     = $(JAVA_HOME)/bin/javac
JARSIGNER = $(JAVA_HOME)/bin/jarsigner

# All sources
SRC = $(shell find src/ -name '*.java')
CLSS= $(SRC:src/%.java=gen/%.class)

all: build
build: out.apk

out.apk: AndroidManifest.xml gen/classes.dex $(KEY_PATH)
	@$(AAPT) p -I $(VEDBASE) -fM AndroidManifest.xml -S res/ -F $@.tmp
	@cp gen/classes.dex . && $(AAPT) a $@.tmp classes.dex && rm -f classes.dex
	@$(JARSIGNER) -keystore $(KEY_PATH) -storepass '$(KEY_PASS)' $@.tmp $(KEY_NAME)
	-@$(ZIPALIGN) -f 4 $@.tmp $@

	-@if [ ! -r "$@" ]; then mv -f $@.tmp $@; fi

gen/classes.dex: prepare $(CLSS)
	-@echo removing R classes to economy some space
	@find gen/ -name 'R.class' -exec rm {} \;
	@find gen/ -name 'R$$*.class' -exec rm {} \;
	@$(DX) --dex --output=$@ gen/

### Helpers

prepare: res/*
	-@echo Generating R.java
	@mkdir -p gen
	@$(AAPT) p -I $(VEDBASE) -fm -M AndroidManifest.xml -J gen -S res

gen/%.class: src/%.java
	-@echo Recompiling $@
	@$(JAVAC) -classpath $(VEDBASE) -sourcepath 'src/:gen/' -d 'gen/' $< -source 1.7 -target 1.7 > /dev/null 2>&1

$(KEY_PATH):
	@yes | keytool -genkey -v -keystore $(KEY_PATH) -storepass '$(KEY_PASS)' -alias $(KEY_NAME) -keypass $(KEY_PASS) -keyalg RSA -keysize 2048 -validity 10000

### Tools

clean:
	rm -rf gen/ classes.dex out.apk out.apk.tmp

deploy: out.apk
	-@$(ADB) uninstall $(CLASS)
	@$(ADB) install $<
	@$(ADB) shell monkey -p $(CLASS) -c android.intent.category.LAUNCHER 1

