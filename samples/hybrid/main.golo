module hybridapp

import m33ki.spark
import m33ki.jackson
import m33ki.hot
import java.lang.String

function main = |args| {
  initialize(): static("/samples/hybrid/public"): port(8888): error(true)

  let DEV_MODE = true
  if DEV_MODE {
    listenForChangeThenCompile(
      "samples/hybrid",
      "samples/hybrid/app"
    )
  }

  # classLoader
  let csl = getClassLoader("samples/hybrid/app")

  # classes
  let human = csl: loadClass("models.Human"): getConstructor(String.class, String.class)

  let humansController = csl: loadClass("controllers.Humans")

  GET("/bob", |request, response| {
    response: type("application/json")

    let bob = human: newInstance("Bob", "Morane")
    println(bob: firstName() + " " + bob: lastName())
    println(bob: toString())

    response: status(200) # 200: OK
    return Json(): toJsonString(bob)

  })

  GET("/somebody", |request, response| {
    response: type("application/json")
    response: status(200) # 200: OK
    return Json(): toJsonString(humansController: newInstance(): giveMeSomebody())

  })

}