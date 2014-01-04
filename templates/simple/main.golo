module main

import m33ki.spark
import m33ki.jackson
import m33ki.hot # requisite for "hot reloading"

# see /app/application.golo
import application

function main = |args| {

  initialize(): static("/public"): port(8888): error(true)

  listenForChange("") # listen to root of the webapp

  # my first little json service
  GET("/about", |request, response| {
    response:type("application/json")
    response: status(200)
    return Json(): toJsonString(map[["message", "Hello World with M33ki!"]])
  })

}
