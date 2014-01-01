module simple

import m33ki.spark
import m33ki.collections
import m33ki.gandalf

function main = |args| {

  initialize(): static("/samples/simple.react.wip/public"): port(8888): error(true)


  CRUD(map[
    ["humans", Collection()],
    ["animals", Collection()]
  ])
}

