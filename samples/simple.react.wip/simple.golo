module simple

import m33ki.spark
import m33ki.collections
import m33ki.gandalf
import m33ki.jackson
import m33ki.hot


function main = |args| {

  initialize(): static("/samples/simple.react.wip/public"): port(8888): error(true)
  listenForChange("/samples/simple.react.wip/")


  CRUD(map[
    ["humans", Collection()],
    ["animals", Collection()]
  ])

  GET("/about", |request, response| {
    response:type("application/json")
    return Json(): toJsonString(map[["message", "Cool ;) !"]])
  })

}

