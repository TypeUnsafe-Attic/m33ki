module simple

import m33ki.spark
import m33ki.collections
import m33ki.gandalf

function main = |args| {

  # static assets
  static("/samples/simple.gandalf/public")
  port(8888)

  CRUD(map[
      ["humans", Collection()]
    , ["animals", Collection()]
  ])
}

