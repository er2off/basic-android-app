# Basic application template

This is basic template of Android application
that does not uses gradle, CMake and others,
just GNU Make.

# Installation

Copy `config.mk.example` to `config.mk` and replace values
with compatible for you.

To just build an APK, run `make`

To deploy to device (connect it before), run `make deploy`

To clean compiled files, run `make clean`

So easy!

# Why this can be useful?

You can learn about android low-level build
processes such as .java's to classes.dex
and magic R class.

# What the hell happens here?

This is the most interesting part!

1. AAPT generates R.class and R$something.class files, so you
   can use R.layout.main instead of some 0xCAFEBABE.

2. Then we are using javac as we are compile Java applications.
   It uses both .java files in src/ and gen/ (when R.class located).

3. To economy some space (in big applications this can be so many!),
   we are removing all R.classes.

4. Then dx utility (another magic utility) generates classes.dex.

5. To install application, we also need key, keytool makes it.

6. AAPT utility packs all of resources and manifest
   (with XMLs to binary format conversion) to zip file.

7. We are adds our classes.dex into zip file.

8. To make app installation possible, we are sign it with prepared key.

9. To reduce application size (especially for big apps) also uses zipalign.

10. PROFIT!

