module hybridapp

import m33ki.spark
import m33ki.jackson
import m33ki.hot
import java.lang.String

import tools

function main = |args| {
  initialize(): static("/public"): port(8888): error(true)

  let DEV_MODE = true
  if DEV_MODE {
    listenForChangeThenCompile(
      "",     # listen to change in root directory (of the web app)
      "classes"   # java source files directory
    )
  }

  # classLoader
  let csl = classLoader("classes")

  # classes
  let human = csl: load("models.Human"): getConstructor(String.class, String.class)

  let ApplicationController = csl: load("controllers.Application")

  GET("/bob", |request, response| {
    response:type("application/json")
    let bob = human: newInstance("Bob", "Morane")
    println(bob: firstName() + " " + bob: lastName())
    println(bob: toString())
    response: status(200) # 200: OK
    return Json(): toJsonString(bob)
  })

  GET("/somebody", |request, response| {
    response:type("application/json")
    response: status(200) # 200: OK
    return Json(): toJsonString(ApplicationController: newInstance(): giveMeSomebody())
  })

  GET("/about", |request, response| {
    response:type("text/html")
    response: status(200) # 200: OK
    return ApplicationController: newInstance(): about()
  })

}