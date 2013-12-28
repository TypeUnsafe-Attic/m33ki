module m33ki.javacompiler

import javax.tools.ToolProvider

import java.io.File
import java.net.URLClassLoader

----
#THIS IS EXPERIMENTAL

  # java classes factory
  let classFactory = loadClasses(
      "samples/hybrid/app"
    , list[
        "models.Human"
      , "controllers.Humans"
      ]
    , true # compilation if needed
  )

  let human = classFactory: load("models.Human"): getConstructor(String.class, String.class)
  let humanNoParameter = classFactory: load("models.Human")

  let humansController = classFactory: load("controllers.Humans")

  let john = humanNoParameter: newInstance()

  println(humansController: newInstance(): giveMeSomebody(): toString())

----
function loadClasses = |javaClassDirectory, classes, compilation| {
  # javaClassDirectory is a string
  # classes is a list of strings
  # compilation is boolean : true -> dev mode
  require(javaClassDirectory oftype java.lang.String.class, "1st parameter of loadClasses must be a String")
  require(classes oftype java.util.LinkedList.class, "2nd parameter of loadClasses must be a list")
  require(compilation oftype java.lang.Boolean.class, "3rd parameter of loadClasses must be a boolean")
  require(File(javaClassDirectory): exists() is true, "This directory : %s doesn't exist": format(javaClassDirectory))

  if compilation is true {

    let hasBeenModifiedOrHasToBeCompiled = |javaSourceFile| {
      let javaFile = File(javaSourceFile)
      let classFileName = javaFile: getName(): split(".java"): get(0) + ".class"
      let directory = javaFile: getAbsolutePath(): split(javaFile: getName()): get(0)
      let classFile = File(directory + classFileName)
      if classFile: exists() is false or (javaFile: lastModified() > classFile: lastModified())is true {
        return true
      } else {
        return false
      }
    }

    let runCompilation = DynamicObject():value(false)
    let classesToCompile = list[]

    classes: each(|className|{
      var javaSourceFile = javaClassDirectory + "/" + className: replace(".","/") + ".java"
      classesToCompile: add("\""+javaSourceFile+"\"")
      # at least one java file has been modified or never been compiled
      if hasBeenModifiedOrHasToBeCompiled(javaSourceFile) is true {
        runCompilation: value(true)
      }
    })

    if classesToCompile: size() > 0 and runCompilation: value() is true {

      let srcToEvaluate = """
        module compilertool

        import javax.tools.ToolProvider

        function compile = {
          let compiler = ToolProvider.getSystemJavaCompiler()
          let results = compiler: run(null, null, null, %s)
        }
      """
      : format(classesToCompile: join(","))

      println(srcToEvaluate)

      #http://stackoverflow.com/questions/2028193/specify-output-path-for-dynamic-compilation
      #http://stackoverflow.com/questions/1563909/how-to-set-classpath-when-i-use-javax-tools-javacompiler-compile-the-source

      let env = gololang.EvaluationEnvironment()
      let compilertool_module = env:asModule(srcToEvaluate)

      let compileClasses = fun("compile", compilertool_module)

      compileClasses()
    }
  }

  # create class loader and "class factory"

  let file = File(javaClassDirectory)
  #let url = file: toURI(): toURL()
  let url = file: toURL()
  let urls = java.lang.reflect.Array.newInstance(java.net.URL.class, 1)
  java.lang.reflect.Array.set(urls, 0, url)

  let cl = URLClassLoader(urls)

  let classFactory = DynamicObject():define("load", |this, className|{
    return cl: loadClass(className)
  })

  return classFactory

}
