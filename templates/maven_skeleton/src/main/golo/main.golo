module main

import m33ki.spark

# === developer mode ===
#import m33ki.hot # requisite for "hot reloading"

import routes

function main = |args| {

  # === production mode (jar) ===
  initialize(): resources("/public"): port(8888): error(true)


  # === developer mode ===
  #initialize(): static("/src/main/resources/public"): port(8888): error(true)
  #listenForChange("src/main/golo/app")
  #listenForChange("") # listen to root of the webapp

  loadRoutes()

}