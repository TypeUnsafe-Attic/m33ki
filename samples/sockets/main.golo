module sockets

import m33ki.spark
import m33ki.jackson
import m33ki.websockets

function main = |args| {

  initialize(): static("/samples/sockets/public"): port(8888): error(true)

  let myServer = WSocket(8887)
    : define("onOpen", |this, dynConn| {
        println(dynConn: uid() + " connected")
      })
    : define("onMessage", |this, dynConn, message| {
        println("> message : " + message + " from "+ dynConn: uid())
        this: sendToAll(message)
        this: sendTo(dynConn, Json(): toJsonString(map[["message", "roger!"]]))
      })
    : define("onClose", |this, dynConn| {
        this: sendToAll(dynConn: uid() + " has exit.")
      })
    : define("onError", |this, dynConn, exception| {
        # foo
      })
    : start()

  println("WebSocket Server connected on " + myServer: port())

  GET("/about", |request, response| {
    response:type("application/json")
    return Json(): toJsonString(map[
      ["websockets_with", "https://github.com/TooTallNate/Java-WebSocket"]
    ])
  })



}

