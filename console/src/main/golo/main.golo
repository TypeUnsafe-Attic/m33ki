module console

import org.apache.commons.io.FileUtils

import java.io.File
import java.io.IOException

import com.fasterxml.jackson.core.JsonProcessingException
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.node.ObjectNode


----
#M33ki console

It's a tool to help you creating project skeleton of M33ki webapps.

##Use

M33ki directory has to be set to PATH, ie:

    sudo pico ~/.bash_profile

    #=== M33ki ===
    M33KI_HOME=/Users/k33g_org/Dropbox/Public/TYPEUNSAFE/m33ki
    export M33KI_HOME
    export PATH=$PATH:$M33KI_HOME

Then, type `m33ki` and follow instructions

##Build it

    mvn compile assembly:single

##Brain Wave

- [http://kodejava.org/how-do-i-copy-directory-with-all-its-contents-to-another-directory/](http://kodejava.org/how-do-i-copy-directory-with-all-its-contents-to-another-directory/)
- [http://www.mkyong.com/java/how-to-set-the-file-permission-in-java/](http://www.mkyong.com/java/how-to-set-the-file-permission-in-java/)
----
function main = |args| {
  require(args: size(): equals(2), "Two arguments needed!")

  let OS = java.lang.System.getProperty("os.name"): toLowerCase()
  let isWindows = -> OS: indexOf("win") >= 0
  let isMac = -> OS: indexOf("mac") >= 0
  let isLinux = -> (OS: indexOf("nix") >= 0) or (OS: indexOf("nux") >= 0)

  println("""
   _____  ________ ________  __   .__
  /     \ \_____  \\_____  \|  | _|__|
 /  \ /  \  _(__  <  _(__  <|  |/ /  |
/    Y    \/       \/       \    <|  |
\____|__  /______  /______  /__|_ \__|
        \/       \/       \/     \/
  WebApp server Golo powered (c) @k33g_org
""")

  println("OS : " + OS)
  #println("isWindows : " + isWindows() + " isMac : " + isMac() + " isLinux : " + isLinux())

  #println("=== M33ki ===")
  let sourceDir = args: get(0)
  let targetDir = args: get(1)

  let appName = readln("Application name?>")

  # === first copy m33ki jar and libs ===

  # m33ki jars
  let sourceDir_m33ki_jars = sourceDir + "/jars"
  let srcDir_m33ki_jars = File(sourceDir_m33ki_jars)

  # m33ki golo libs
  let sourceDir_m33ki_libs = sourceDir + "/libs"
  let srcDir_m33ki_libs = File(sourceDir_m33ki_libs)

  # destination directory
  # this directory doesn't exists
  # and will be created during the copy directory process.
  let targetDir_application = targetDir + "/" + appName
  let tgtDir_application = File(targetDir_application)
  let tgtDir_application_jars = File(targetDir_application + "/jars")
  let tgtDir_application_libs = File(targetDir_application + "/libs")

  # Copy source directory into destination directory
  # including its child directories and files. When
  # the destination directory is not exists it will
  # be created. This copy process also preserve the
  # date information of the file.

  println("Creating %s application":format(appName))
  try {
    println("1- copy %s to %s":format(sourceDir_m33ki_jars, targetDir_application))
    FileUtils.copyDirectory(srcDir_m33ki_jars, tgtDir_application_jars)
    println("2- copy %s to %s":format(sourceDir_m33ki_libs, targetDir_application))
    FileUtils.copyDirectory(srcDir_m33ki_libs, tgtDir_application_libs)
    println("")

    #let applications = map[
    #    ["1", ["Simple", "simple"]]
    #  , ["2", ["REST routes skeleton", "rest"]]
    #  , ["3", ["Hybrid (Golo + Java)", "hybrid"]]
    #]
    #println(applications)

    var applications = null

    if fileExists(sourceDir+"/m33ki.json") {
      println("reading configuration file")
      let jsonConf = fileToText(sourceDir+"/m33ki.json", "UTF-8")

      let mapper = ObjectMapper()
      let jsonNode = mapper: readValue(jsonConf, JsonNode.class)

      applications = mapper: treeToValue(jsonNode, java.util.LinkedHashMap.class)

      #println(linkedHMap)


    } else {
      raise("Where is the m33ki.json?!")
    }

    # TODO: configuration file
    #, ["4", ["Hybrid (Golo + Java) + REST Routes", "hybridrest"]]
    #, ["5", ["Gandalf : CRUD Webapp + backbone", "gandalf"]]

    # choose kind of application
    println("What kind of application ?")

    applications: each(|key, app|{
      println(key + "- " + app: get(0))
    })

    let kindOfApplication = readln("number?>")

    let choice = applications: get(kindOfApplication)

    if choice isnt null {

      println("Creating %s ...":format(choice: get(0)))

      FileUtils.copyDirectory(
          File(sourceDir + "/templates/" + choice: get(1))
        , tgtDir_application
      )

      println("")
      println("%s application has been created": format(appName))
      println("Last steps :")
      println("- type : cd %s": format(appName))
      #println("- type (once) : chmod a+x go.sh")
      println("")

      if(isWindows() isnt true) {
        println("Now, to start the application just type : ./go.sh")
        # only *nix
        let goFile = File(targetDir + "/" + appName + "/go.sh")
        goFile: setExecutable(true)
        goFile: setReadable(true)
        goFile: setWritable(true)
      } else {
        println("Now, to start the application just type : go.bat")
      }

      println("Have fun!")

    } else {
      println("This is not in the list, bye :)")
      java.lang.System.exit(0)
    }

  } catch(e) {
    e: printStackTrace()
  }

}

