module main

import m33ki.spark
import m33ki.hot # requisite for "hot reloading"

import routes

function main = |args| {

  initialize(): static("/public"): port(8888): error(true)
  #listenForChange("app")
  listenForChange("") # listen to root of the webapp

  loadRoutes()

}