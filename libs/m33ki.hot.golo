module m33ki.hot

#import org.apache.commons.jci.compilers.CompilationResult
import org.apache.commons.jci.compilers.EclipseJavaCompiler
import org.apache.commons.jci.compilers.EclipseJavaCompilerSettings
#import org.apache.commons.jci.listeners.CompilingListener
import org.apache.commons.jci.monitor.FilesystemAlterationMonitor
#import org.apache.commons.jci.problems.CompilationProblem
import org.apache.commons.jci.readers.FileResourceReader
import org.apache.commons.jci.stores.FileResourceStore

import java.io.File
import java.net.URLClassLoader

#TODO: rename(?)
#TODO: listenForJavaChange, GoloChange, etc. ...
function listenForChange = |path| {
  let conf = map[
    ["extends", "org.apache.commons.jci.listeners.FileChangeListener"],
    ["implements", map[
      ["onDirectoryChange", |this, pDir| {
        println("Content in " + pDir: getName() + " has changed ....")
        println("Application is restarting ...")
        #java.lang.Runtime.getRuntime(): halt(1)
        java.lang.System.exit(1)
      }]
    ]]
  ]

  let listener = AdapterFabric()
    : maker(conf)
    : newInstance()

  let fam = FilesystemAlterationMonitor()
  fam: addListener(java.io.File( java.io.File("."): getCanonicalPath() + "/" + path), listener)
  fam: start()

}

----
- parameters : String sourcePath, String targetPath, String[] classes
----
function JCompiler = |sourcePath, targetPath, classes| {

  let sourceDir = File(sourcePath)
  println("sourcePath : " + sourcePath)
  let targetDir = File(targetPath)
  println("targetPath : " + targetPath)

  let settings = EclipseJavaCompilerSettings()
  settings: setSourceVersion("1.7")
  let compiler = EclipseJavaCompiler(settings)

  let kompiler = DynamicObject()
    : result(null)  # CompilationResult
    : define("compile", |this| {

        let result = compiler: compile(
            classes
          , FileResourceReader(sourceDir)
          , FileResourceStore(targetDir)
        )

        this: result(result)

        # Compilation Warnings
        # TODO: try catch finally
        println( result: getWarnings(): length() + " warnings")
        if result: getWarnings(): length() > 0 {
          result: getWarnings(): asList(): each(|compilationProblem|{ # CompilationProblem
            println("- " + compilationProblem)
          })
        }

        # Compilation Errors
        # TODO: try catch finally
        println( result: getErrors(): length() + " errors")
        if result: getErrors(): length() > 0 {
          result: getErrors(): asList(): each(|compilationProblem|{ # CompilationProblem
            println("- " + compilationProblem)
          })
          return false
        } else {
          return true
        }

      })
    : define("getClassLoader", |this| {
        let file = targetDir
        #let url = file: toURI(): toURL()
        let url = file: toURL()
        let urls = java.lang.reflect.Array.newInstance(java.net.URL.class, 1)
        java.lang.reflect.Array.set(urls, 0, url)

        let cl = URLClassLoader(urls)
        return cl
      })

  return kompiler

}

----
- parameters : String path (start), String extension, list[] listOfFiles, String root (root path)
----
function filesDiscover = |path, extension, listOfFiles, root| {
  let start_root = java.io.File(path)
  let files = start_root: listFiles(): asList()

  files: each(|file|{
    if file: isDirectory() is true {
      filesDiscover(file: getAbsolutePath(), extension, listOfFiles, root)
    } else {
      if file: getAbsoluteFile(): getName(): endsWith("."+extension) {
        var javaFileName = file: getAbsoluteFile(): toString(): split(root):get(1)
        println("--> " + javaFileName)
        listOfFiles: add(javaFileName)
      }
    }
  })

  return listOfFiles
}


function javaCompile = |path| {

  #let classes = java.lang.reflect.Array.newInstance(java.lang.String.class, 2)
  #java.lang.reflect.Array.set(classes, 0, "models/Human.java")
  #java.lang.reflect.Array.set(classes, 1, "controllers/Humans.java")

  let javaFiles = filesDiscover(path, "java", list[], path)
  #println(javaFiles)

  let numberOfJavaFiles = javaFiles: size()
  let classes = java.lang.reflect.Array.newInstance(java.lang.String.class, numberOfJavaFiles)
  let index = DynamicObject(): value(0): define("increment",|this|-> this: value(this: value() + 1))
  javaFiles: each(|filePathName| {
    java.lang.reflect.Array.set(classes, index: value(), filePathName: toString())
    index: increment()
  })

  let compiler = JCompiler(
      path  # source path
    , path  # target path
    , classes
  )

  let res = compiler: compile()
  if res is false {
    #java.lang.System.exit(1)
  }

}

function listenForChangeThenCompile = |path, javaSourcePath| {
  let conf = map[
    ["extends", "org.apache.commons.jci.listeners.FileChangeListener"],
    ["implements", map[
      ["onDirectoryChange", |this, pDir| {
        println("Content in " + pDir: getName() + " has changed ....")

        println("Java classes compiling ...")
        javaCompile(javaSourcePath)

        println("Application is restarting ...")
        #java.lang.Runtime.getRuntime(): halt(1)
        java.lang.System.exit(1)
      }]
    ]]
  ]

  let listener = AdapterFabric()
    : maker(conf)
    : newInstance()

  let fam = FilesystemAlterationMonitor()
  fam: addListener(java.io.File( java.io.File("."): getCanonicalPath() + "/" + path), listener)
  fam: start()

}

function getClassLoader = |targetPath| {
  let targetDir = File(targetPath)
  #println("targetPath : " + targetPath)
  let file = targetDir
  #let url = file: toURI(): toURL()
  let url = file: toURL()
  let urls = java.lang.reflect.Array.newInstance(java.net.URL.class, 1)
  java.lang.reflect.Array.set(urls, 0, url)

  let cl = URLClassLoader(urls)
  return cl
}
