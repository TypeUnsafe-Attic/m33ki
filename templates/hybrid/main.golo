module hybridapp

import m33ki.spark
import m33ki.jackson

import java.lang.String

import app.models.Human
import app.controllers.Application

import config

function main = |args| {
  initialize(): static("/public"): port(8888): error(true)
  listen(true) # listen to change, then compile java file

  GET("/bob", |request, response| {
    response: type("application/json")
    let bob = Human("Bob", "Morane")
    println(bob: firstName() + " " + bob: lastName())
    println(bob: toString())
    response: status(200) # 200: OK
    return Json(): toJsonString(bob)
  })

  GET("/somebody", |request, response| {
    response: type("application/json")
    response: status(200) # 200: OK
    return Json(): toJsonString(Application(): giveMeSomebody())
  })

  GET("/about", |request, response| {
    response: type("text/html")
    response: status(200) # 200: OK
    return Application(): about()
  })

}