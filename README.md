#J2OBJC plugin

This is a clean reboot of the now deprecated [j2objc-gradle project](https://github.com/google/j2objc)

Due to my allergy for groovy and love for [xtend](https://eclipse.org/xtend/download.html) + gradle, I decided
to write a smaller gradle plugin for j2objc.

## Get started

### J2Objc from git

From a terminal:
```
git clone git@github.com:google/j2objc.git
cd j2objc ; make dist
pwd # use this location for `local.properties` and/or `.bashrc`
```

1. add a line to your environment variables `.bashrc` (assuming you use bash) and enter `export J2OBJC_HOME="${HOME}/where-you-put-it/j2objc/dist"`
2. or add a line to your `local.properties` like this: `j2objc.home=/User/user/where-you-put-it/j2objc/dist`


### The plugin
You need gradle and [j2objc](https://github.com/google/j2objc) to build this gradle plugin project.

Go to the directory, enter command line instructions:
```
gradle wrapper # for the first time, not necessary when the wrapper has been created
./gradlew build
```

### IDE Support (e.g. Intellij / Android Studio)
[Follow these instructions to install the xtend plugin for your IDE.](https://eclipse.org/xtend/download.html)


