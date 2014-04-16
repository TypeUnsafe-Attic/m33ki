module main

import m33ki.spark
import m33ki.hot # requisite for "hot reloading"

import config
import routes

import acme

function main = |args| {

  initialize(): static("/public"): port(8888)
  listen(true) # listen to change, then compile java file

  loadRoutes()

}