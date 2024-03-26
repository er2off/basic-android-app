# Application information
# Read from manifest
CLASS= $(shell grep -Po '(?<=package=")[^"]+' AndroidManifest.xml)
MIN_SDK= $(shell grep -Po '(?<=android:minSdkVersion=")[^"]+' AndroidManifest.xml)
MAX_SDK= $(shell grep -Po '(?<=android:targetSdkVersion=")[^"]+' AndroidManifest.xml)

include config.mk

# All sources
SRC = $(shell find src/ -name '*.java')
CLSS= $(SRC:src/%.java=work/java/%.class)
RES = $(wildcard res/*/*)

all: build
build: work/out.apk

work/out.apk: AndroidManifest.xml work/classes.dex work/res.apk $(KEY_PATH)
	@mkdir -p work
	@cp work/res.apk $@.tmp
	@zip -ju $@.tmp work/classes.dex
#	@zip -ur $@.tmp assets lib
ifneq ($(APKSIGNER),)
# zipalign strictly before apksigner (but after jarsigner)
	@$(ZIPALIGN) -f 4 $@.tmp $@
	@$(APKSIGNER) sign --ks $(KEY_PATH) --ks-pass 'pass:$(KEY_PASS)' --min-sdk-version=$(MIN_SDK) --max-sdk-version=$(MAX_SDK)  $@
else
# Use jarsigner instead of apksigner
# because apksigner produces bigger apk
	@$(JARSIGNER) -keystore $(KEY_PATH) -storepass '$(KEY_PASS)' $@.tmp $(KEY_NAME)
	@$(ZIPALIGN) -f 4 $@.tmp $@
endif
	-@rm $@.tmp

work/classes.dex: $(RES_OUT) $(CLSS)
	-@echo Generating classes.dex
	@$(D8) --release --output work --min-api $(MIN_SDK) --lib $(VEDBASE) $$(find work/java -name '*.class' -not -name 'R.class' -not -name 'R$$*.class')

### Resources

# Fix extensions and path
# values/% becomes values_%.arsc.flat
# etc/% becomes etc_%.flat
## NOTE: $V is template variable
_RES_FIX=	$(subst /,_,$(if $(filter values%,$V),$(V:%.xml=%.arsc),$V)).flat

# Use stable ids with libraries
work/ids.txt: $(RES) $(LIBS)
	@echo> $@
# uncomment this if you want to have libraries
#	$(foreach L,$(LIBS),cat $(ROOTDIR)/$L/work/R.txt >> work/ids.txt)
#	@sed 's/^.*:/$(CLASS):/g' $@

#RES+=		$(foreach V,$(subst $(APPDIR)/src/res/,,$(RES_SRC)),$(WRKDIR)/res/$(_RES_FIX))

AAPT2_FLAGS = -o $@ --stable-ids work/ids.txt -I $(AAPT2JAR) --auto-add-overlay --manifest AndroidManifest.xml $(LIBS_RES) $(RES_OUT)

define _mkRes
RES_OUT += $2
$2: $1
	-@echo Compiling resource $1
	@$(AAPT2) compile -o $(dir $2) $1
endef
$(shell mkdir -p work/res)
$(foreach V,$(subst res/,,$(RES)),\
	$(eval $(call _mkRes,res/$V,work/res/$(_RES_FIX))))

work/res.apk: AndroidManifest.xml $(RES_OUT) work/ids.txt
	-@echo Generating res.apk and R.java
	@mkdir -p work/java
# emit-ids here for libraries
	@$(AAPT2) link --emit-ids work/R.txt --java work/java $(AAPT2_FLAGS)

### Helpers

work/java/%.class: src/%.java work/res.apk
	-@echo Compiling $<
	@$(JAVAC) -classpath $(VEDBASE) -sourcepath 'src/:work/java/' -d 'work/java/' $< -source 8 -target 8 -Xlint:-options

$(KEY_PATH):
	@yes | keytool -genkey -v -keystore $(KEY_PATH) -storepass '$(KEY_PASS)' -alias $(KEY_NAME) -keypass $(KEY_PASS) -keyalg RSA -keysize 2048 -validity 10000

### Tools

clean:
	rm -rf work/

deploy: work/out.apk
	@$(PM) uninstall $(CLASS)
	@$(PM) install $<
	@$(MONKEY) -p $(CLASS) -c android.intent.category.LAUNCHER 1
