package com.github.buggaboo.j2objc.gradle

import org.gradle.api.DefaultTask
import org.gradle.api.tasks.TaskAction
import org.gradle.api.Plugin
import org.gradle.api.Project
import org.eclipse.xtend.lib.annotations.Accessors

import org.gradle.api.tasks.TaskExecutionException
import java.util.Properties
import java.io.File
import java.io.FileWriter
import java.io.BufferedWriter
import java.io.IOException


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
        project.extensions.create("SymlinkSettings", SymlinkExtension)

        // Usage: just extend this task and do something with it...
        val SymLinkFrameworkTask = project.tasks.create("SymLinkFramework", IosFrameworkSymlinkTask)
    }
}