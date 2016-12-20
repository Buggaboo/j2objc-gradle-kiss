package com.github.buggaboo.j2objc.gradle

import org.gradle.api.Task
import org.gradle.api.DefaultTask
import org.gradle.api.tasks.TaskAction
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.eclipse.xtend.lib.annotations.Accessors

import java.io.File
import java.io.FileWriter
import java.io.BufferedWriter
import java.io.IOException
import java.util.List
import java.util.ArrayList
import java.util.Collection

/**
 * Translate all java files and put them somewhere
 */
class J2ObjcConfigExtension {
    List<String> includePatterns = new ArrayList<String>()
    List<String> excludePatterns = new ArrayList<String>()
    List<String> mTranslateArgs = new ArrayList<String>()
    List<String> mCompileArgs = new ArrayList<String>()

    new () {}

    new (Task task) {
        // TODO enter defaults
        // task.inputs.property ('', new Object) // TODO determine utility
    }

    @Accessors
    boolean runTests

    @Accessors
    String minVersionIos

    @Accessors
    boolean createFramework

    def void translateArgs(String... args) {
        for(a : args) {
            mCompileArgs.add(a)
        }
    }

    def void translateArgs(Collection<String> args) {
        mTranslateArgs.addAll(args)
    }

    def void compileArgs(String... args) {
        for(a : args) {
            mCompileArgs.add(a)
        }
    }

    def void compileArgs(Collection<String> args) {
        mCompileArgs.addAll(args)
    }

    def void exclude(String pattern) {
        excludePatterns.add(pattern)
    }

    def void excludes(Collection<String> patterns) {
        excludePatterns.addAll(patterns)
    }

    def void include(String pattern) {
        includePatterns.add(pattern)
    }

    def void includes(Collection<String> patterns) {
        includePatterns.addAll(patterns)
    }
}


/**
 * Create symlink for the frameworks
 */
class IosFrameworkSymlinkTask extends DefaultTask
{
    static val runtime = Runtime.runtime

    static def void symlinkFramework(String location, String name)
    {
        var fileContent = '''
            #!/bin/sh

            /bin/ln -sfh Versions/Current/Headers Headers
            /bin/ln -sfh Versions/Current/«name» «name»
            cd Versions ; /bin/ln -sfh A Current
        '''

        new File('''«location»/symlink.sh''').writeContentToFile(fileContent)

        var p = runtime.exec('''/bin/chmod +x «location»/symlink.sh''')
        p.waitFor
        /*
        p = runtime.exec("/bin/sh -c 'cd «location» ; ./symlink.sh'")
        p.waitFor
        */
        p = runtime.exec("./symlink.sh", null, new File(location))
        p.waitFor
    }

    static def File writeContentToFile(File file, String content)
    {
        try {

            // if file doesnt exists, then create it
            if (!file.exists) {
                file.createNewFile
            }

            val fw = new FileWriter(file.getAbsoluteFile)
            val bw = new BufferedWriter(fw)
            bw.write(content)
            bw.close

        } catch (IOException e) {
            e.printStackTrace
        }

        return file
    }

    @TaskAction
    def void symlink()
    {
        var ext = project.extensions.findByType(SymlinkExtension)
        var name = ext.frameworkName
        var debugLoc = ext.debugLocation
        var releaseLoc = ext.releaseLocation

        debugLoc.symlinkFramework(name)
        releaseLoc.symlinkFramework(name)
    }
}

class SymlinkExtension
{
    @Accessors
    var String frameworkName

    @Accessors
    var String debugLocation

    @Accessors
    var String releaseLocation
}

class J2ObjcPlugin implements Plugin<Project>
{
    override apply(Project project) {
        // IosFrameworkSymlinkTask
        project.extensions.create("symlinkConfig", SymlinkExtension)
        project.extensions.create("j2objcConfig", J2ObjcConfigExtension)

        // Usage: just extend this task and do something with it...
        val SymLinkFrameworkTask = project.tasks.create("SymLinkFramework", IosFrameworkSymlinkTask)
    }
}

/**
sources:
- http://www.thinkcode.se/blog/2015/03/22/a-gradle-plugin-written-in-java
- http://mrhaki.blogspot.nl/2016/03/gradle-goodness-adding-custom-extension.html
- https://leanpub.com/gradle-goodness-notebook/read
- https://github.com/hierynomus/license-gradle-plugin/blob/master/src/main/groovy/nl/javadude/gradle/plugins/license/LicenseExtension.groovy
- https://github.com/hierynomus/license-gradle-plugin
- http://www.slideshare.net/ysb33r/idiomatic-gradle-plugin-writing
*/