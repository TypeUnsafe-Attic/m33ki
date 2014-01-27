module main

import m33ki.spark
import m33ki.hot # requisite for "hot reloading"

import application    # see /app/application.golo
import all.routes         # see /app/all.routes.golo

function main = |args| {

  initialize(): static("/public"): port(8888): error(true)
  listenForChange("app") # listen to root of the webapp
  defineRoutes()

}
