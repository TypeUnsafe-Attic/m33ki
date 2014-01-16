module config

import m33ki.hot

function listen = |DEV_MODE| {
  require(DEV_MODE oftype java.lang.Boolean.class, "DEV_MODE have to be a Boolean")

  compileIfNotJar("classes", "app", "jars", "application.000")

  # delete application jar file to force compilation at start

  #compileAndCreateJar("classes", "app", "jars", "application.000")

  if DEV_MODE {
    listenForChangeThenCompile(
        ""                    # listen to change (all files) in root directory (of the web app)
      , "classes"             # java source files directory
      , "app"                 # package base name
      , "jars"                # target directory for jar
      , "application.000"     # application jar name
    )
  }
}

