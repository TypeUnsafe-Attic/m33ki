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

  # Create a model
  POST("/models", |request, response| {
    response:type("application/json")
    println(request: body())
    response: status(201) # 201: created
    return Json(): toJsonString(map[["message", "this is a POST request"]])
  })

  # Retrieve all models
  GET("/models", |request, response| {
    response:type("application/json")
    return Json(): toJsonString(map[["message", "this is a GET request"]])
  })

  # Retrieve a model by id
  GET("/models/:id", |request, response| {
    response:type("application/json")
    let id = request: params(":id")
    return Json(): toJsonString(map[["message", "this is a GET request with id="+id]])
  })

  PUT("/models/:id", |request, response| {
    response:type("application/json")
    println(request: body())
    let id = request: params(":id")
    return Json(): toJsonString(map[["message", "this is a PUT request with id="+id]])
  })

  DELETE("/models/:id", |request, response| {
    response:type("application/json")
    let id = request: params(":id")
    return Json(): toJsonString(map[["message", "this is a DELETE request with id="+id]])
  })

}
