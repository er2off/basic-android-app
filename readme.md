# Basic application template

This is basic template of Android application
that does not uses gradle, CMake and others,
just GNU Make.

This template uses newer AAPT2 and D8 unlike most
others Makefile projects for Android.

# Installation

Copy `conf/config.example.mk` to `config.mk` and replace values
with compatible for you.

To just build an APK, run `make`

To deploy to device (connect it before), run `make deploy`

To clean compiled files, run `make clean`

So easy!

# Why this can be useful?

You can learn more about Android low-level build
processes such as .java's to classes.dex translation
and magic R class.
Also you can learn about modern Android build tools
such as aapt2 and d8 (replacements of aapt and dx).

# What the hell happens here?

This is the most interesting part!

1. AAPT2 compiles res/ files into \*.flat files into directory.
  Also it uses weird output file naming:
  - slashes are changed with underscores and .flat extension is added
  - BUT for values/ it also replaces .xml with .arsc for some reason.

2. AAPT2 links resources to res.apk and generates R\*.class files, so you
   can use R.layout.main instead of some 0xCAFEBABE.

3. Then we are using javac in the same way as usual Java applications.
   It uses both .java files in src/ and work/java/ (where R.class located).

4. Then d8 utility (another magic utility) generates classes.dex.
  This utility also can convert Java8+ features into Android-compatible ones.
  Additionally to economy some space, in this makefile R.classes are excluded from list (however, this can break some apps so keep in mind).

6. To install application, we also need key, keytool makes it.

7. We are using zip to add classes.dex and everything other (such as assets/ or lib/) into copy of res.apk

8. To speed up application and maybe even reduce its size, we are using zipalign.

9. To make app installation possible, we sign it with generated key.
  Note that when use javasigner, first sign and then zipalign.

10. PROFIT!
