module m33ki.hot

import org.apache.commons.jci.monitor.FilesystemAlterationMonitor

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
  fam: addListener(java.io.File( java.io.File("."): getCanonicalPath() + path), listener)
  fam: start()

}