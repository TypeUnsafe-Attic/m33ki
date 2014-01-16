module m33ki.hot

#import org.apache.commons.jci.compilers.CompilationResult
import org.apache.commons.jci.compilers.EclipseJavaCompiler
import org.apache.commons.jci.compilers.EclipseJavaCompilerSettings
#import org.apache.commons.jci.listeners.CompilingListener
import org.apache.commons.jci.monitor.FilesystemAlterationMonitor
#import org.apache.commons.jci.problems.CompilationProblem
import org.apache.commons.jci.readers.FileResourceReader
import org.apache.commons.jci.stores.FileResourceStore

#import org.apache.commons.io.FileUtils

import java.io.File
import java.net.URLClassLoader

import java.io.BufferedOutputStream
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.InputStream

import org.apache.commons.compress.archivers.zip.ZipArchiveEntry
import org.apache.commons.compress.archivers.zip.ZipArchiveOutputStream
import org.apache.commons.compress.archivers.zip.ZipFile
import org.apache.commons.compress.utils.IOUtils


function listenForChange = |path| {
  println("Listening on " + java.io.File("."): getCanonicalPath() + "/" + path)
  let conf = map[
    ["extends", "org.apache.commons.jci.listeners.FileChangeListener"],
    ["implements", map[
      ["onDirectoryChange", |this, pDir| {
        println("Content in " + pDir: getName() + " has changed ....")
        #println("Application is restarting ...")
        #java.lang.Runtime.getRuntime(): halt(1)
        #java.lang.System.exit(1)
      }],
      ["onFileChange", |this, pFile| {

        if pFile: getName(): endsWith(".golo") {
          println("File " + pFile: getName() + " has changed ....")
          println("Application is restarting ...")
          #java.lang.Runtime.getRuntime(): halt(1)
          java.lang.System.exit(1)
        }

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
  #println("path : " + path + " root : " + root)
  let start_root = java.io.File(path)
  let files = start_root: listFiles(): asList()

  files: each(|file|{
    if file: isDirectory() is true {
      #println("this is a directory : " + file: getAbsolutePath())
      filesDiscover(file: getAbsolutePath(), extension, listOfFiles, root)
    } else {
      if file: getAbsoluteFile(): getName(): endsWith("." + extension) is true {
        var javaFileName = file: getAbsolutePath(): toString(): split(root): get(1)
        #TODO : other method because pb if app in the application name
        println("--> " + javaFileName)
        listOfFiles: add(javaFileName)
      }
    }
  })

  return listOfFiles
}


function javaCompile = |path| {

  let OS = java.lang.System.getProperty("os.name"): toLowerCase()
  let isWindows = -> OS: indexOf("win") >= 0
  let isMac = -> OS: indexOf("mac") >= 0
  let isLinux = -> (OS: indexOf("nix") >= 0) or (OS: indexOf("nux") >= 0)

  let javaFiles = filesDiscover(path, "java", list[], path)
  #println(javaFiles)

  let numberOfJavaFiles = javaFiles: size()

  let classes = java.lang.reflect.Array.newInstance(java.lang.String.class, numberOfJavaFiles)

  let index = DynamicObject(): value(0): define("increment",|this|-> this: value(this: value() + 1))

  javaFiles: each(|filePathName| {
    
    if isWindows() is true {
      var newFilePathName = filePathName: toString(): replaceAll("\\\\", "/")
      #println(">>===> " + newFilePathName)
      java.lang.reflect.Array.set(
          classes
        , index: value()
        , newFilePathName
      )
    } else { # OSX or Linux
      java.lang.reflect.Array.set(classes, index: value(), filePathName: toString())
    }
    
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

function listenForChangeThenCompile = |path, javaSourcePath, packageBaseName, jarPath, jarName| {
  let conf = map[
    ["extends", "org.apache.commons.jci.listeners.FileChangeListener"],
    ["implements", map[
      ["onDirectoryChange", |this, pDir| {
        println("Content in " + pDir: getName() + " has changed ....")

        #println("Java classes compiling ...")
        #javaCompile(javaSourcePath)

        #println("Jar creating ...")
        #createZip(java.io.File(javaSourcePath): getAbsolutePath() +"/"+packageBaseName, java.io.File(jarPath): getAbsolutePath()+"/"+jarName+".jar")

        #println("Application is restarting ...")
        #java.lang.System.exit(1)
      }],
      ["onFileChange", |this, pFile| {

        if pFile: getName(): endsWith(".java") or pFile: getName(): endsWith(".golo") {
          println("File " + pFile: getName() + " has changed ....")

          if pFile: getName(): endsWith(".java") {
            println("Java classes compiling ...")
            javaCompile(javaSourcePath)

            println("Jar creating ...")
            createZip(java.io.File(javaSourcePath): getAbsolutePath() +"/"+packageBaseName, java.io.File(jarPath): getAbsolutePath()+"/"+jarName+".jar")
          }

          println("Application is restarting ...")
          #java.lang.Runtime.getRuntime(): halt(1)
          java.lang.System.exit(1)
        }

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

function compileAndCreateJar = |javaSourcePath, packageBaseName, jarPath, jarName| {
    println("Compiling and creating jar application")
    println("Java classes compiling ...")
    javaCompile(javaSourcePath)
    println("Jar creating ...")
    createZip(java.io.File(javaSourcePath): getAbsolutePath() +"/"+packageBaseName, java.io.File(jarPath): getAbsolutePath()+"/"+jarName+".jar")
    println("Application is restarting ...")
    java.lang.System.exit(1)
}

function doesThisJarExist = |jarPath, jarName| -> File(java.io.File(jarPath): getAbsolutePath()+"/"+jarName+".jar"): exists()

# deprecated
function atLeastOneFileYoungerThanJar = |javaSourcePath, jarPath, jarName| {
  let javaFiles = filesDiscover(javaSourcePath, "java", list[], javaSourcePath)
  let runCompilation = DynamicObject():value(false)

  javaFiles: each(|filePathName| {
    var javaFile = File(filePathName)
    if javaFile: lastModified() < File(java.io.File(jarPath): getAbsolutePath()+"/"+jarName+".jar"): lastModified() {
      runCompilation: value(true)
    }
  })
  return runCompilation: value()
}

function compileIfNotJar = |javaSourcePath, packageBaseName, jarPath, jarName| {

  if File(java.io.File(jarPath): getAbsolutePath()+"/"+jarName+".jar"): exists() isnt true {
    println("First time ...")
    println("Java classes compiling ...")
    javaCompile(javaSourcePath)
    println("Jar creating ...")
    createZip(java.io.File(javaSourcePath): getAbsolutePath() +"/"+packageBaseName, java.io.File(jarPath): getAbsolutePath()+"/"+jarName+".jar")
    println("Application is restarting ...")
    java.lang.System.exit(1)
  }

}

function addFileToZip = |zOut, path, base| {
  # ZipArchiveOutputStream
  # String
  # String

  let f = File(path)                            # File
  let entryName = base + f: getName()           # String
  let zipEntry = ZipArchiveEntry(f, entryName)  # ZipArchiveEntry

  zOut: putArchiveEntry(zipEntry)

  if f: isFile() is true {
    var fInputStream = null     # FileInputStream
    try {
      fInputStream = FileInputStream(f)
      IOUtils.copy(fInputStream, zOut)
      zOut: closeArchiveEntry()
      fInputStream: close()
    } catch (e) {
      e: printStackTrace()
    } finally {
      #if fInputStream isnt null {
      #  IOUtils.closeQuietly(fInputStream)
      #}
    }

  } else {
    zOut: closeArchiveEntry()
    let children = f: listFiles()   # File[] 

    if (children != null) is true {
        foreach child in children {
            addFileToZip(zOut, child: getAbsolutePath(), entryName + "/")
        }
    }
  } # end else

}

function createZip = |directoryPath, zipPath| {
  # String
  # String
  var fOut = null     # FileOutputStream
  var bOut = null     # BufferedOutputStream
  var tOut = null     # ZipArchiveOutputStream

  try {
    fOut = FileOutputStream(File(zipPath))
    bOut = BufferedOutputStream(fOut)
    tOut = ZipArchiveOutputStream(bOut)
    addFileToZip(tOut, directoryPath, "")
  } catch (e) {
    e: printStackTrace()
  } finally {
    tOut: finish()
    tOut: close()
    bOut: close()
    fOut: close()
  }

}


----
  # classLoader
  let csl = getClassLoader("samples/hybrid/app")

  # classes
  let human = csl: loadClass("models.Human"): getConstructor(String.class, String.class)

  let humansController = csl: loadClass("controllers.Humans")
----
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

function classLoader = |targetPath| {
  let cl = getClassLoader(targetPath)

  return DynamicObject()
    :define("load", |this, className|{
      var klass = null
      try {
        klass = cl: loadClass(className)
        return klass
      } catch (e){
        println("Update source code and save ...")
      }
    })
}
