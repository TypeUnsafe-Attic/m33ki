module hi

import org.apache.commons.io.FileUtils

import java.io.File
import java.io.IOException

import com.fasterxml.jackson.core.JsonProcessingException
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.node.ObjectNode


----
#hiM33ki (Generator)

----
function main = |args| {
  require(args: size(): equals(2), "Two arguments needed!")

  let OS = java.lang.System.getProperty("os.name"): toLowerCase()
  let isWindows = -> OS: indexOf("win") >= 0
  let isMac = -> OS: indexOf("mac") >= 0
  let isLinux = -> (OS: indexOf("nix") >= 0) or (OS: indexOf("nux") >= 0)

  println("""
.__    .__   _____  ________ ________  __   .__
|  |__ |__| /     \ \_____  \\_____  \|  | _|__|
|  |  \|  |/  \ /  \  _(__  <  _(__  <|  |/ /  |
|   Y  \  /    Y    \/       \/       \    <|  |
|___|  /__\____|__  /______  /______  /__|_ \__|
     \/           \/       \/       \/     \/
  M33ki Generator (c) @k33g_org
""")

  println("OS : " + OS)
  #println("isWindows : " + isWindows() + " isMac : " + isMac() + " isLinux : " + isLinux())

  #println("=== M33ki ===")
  let sourceDir = args: get(0)
  let targetDir = args: get(1)

  # check
  println("source dir : " + sourceDir)
  println("target dir : " + targetDir)

  # end check

  let sourceDir_generators = sourceDir + "/generators"
  let srcDir_generators = File(sourceDir_generators)

  # destination directory
  # this directory doesn't exists
  # and will be created during the copy directory process.
  #let targetDir_application = targetDir + "/" + appName
  #let tgtDir_application = File(targetDir_application)
  #let tgtDir_application_jars = File(targetDir_application + "/jars")
  #let tgtDir_application_libs = File(targetDir_application + "/libs")

  println("=== M33ki Generators ===")
  try {
    var generators = null

    if fileExists(sourceDir+"/him33ki.json") {
      let jsonConf = fileToText(sourceDir+"/him33ki.json", "UTF-8")
      let mapper = ObjectMapper()
      let jsonNode = mapper: readValue(jsonConf, JsonNode.class)
      generators = mapper: treeToValue(jsonNode, java.util.LinkedHashMap.class)
    } else {
      raise("Where is the him33ki.json?!")
    }

    println("=== What kind of generator ? ===")
    println("")
    let generatorsMenu = {
      # choose kind of generator

      generators: each(|key, app|{
        println(key + "- " + app: get(0))
      })

      let kindOfGenerator = readln("generator number (0:exit)?>")

      let choice =  generators: get(kindOfGenerator)

      if choice isnt null {

        #println("Choice %s %s ...":format(choice: get(0), choice: get(1)))

        ### Load and execute generator

        	let env = gololang.EvaluationEnvironment()
          #TODO: try catch
          let generator_module = env:asModule(fileToText(sourceDir_generators+"/"+choice: get(1)+".golo", "UTF-8"))

        	let generator = fun("generator", generator_module)

        	generator(targetDir)

        ### end of generator execution

      } else {
        println("This is not in the list, bye :)")
        java.lang.System.exit(0)
      }

    }

    while true { generatorsMenu() }

  } catch(e) {
    e: printStackTrace()
  }

}

