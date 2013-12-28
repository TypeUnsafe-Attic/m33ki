module sockets

import m33ki.spark
import m33ki.jackson

augment org.java_websocket.server.WebSocketServer {
  function sendToAll = |this, text| {
    let con = this: connections()
    println(text)
    let semaphore = java.util.concurrent.Semaphore(1)
    semaphore: acquire()
    con: each(|cx|{
      cx: send(text)
    })
    semaphore: release()
  }
}

function main = |args| {

  # static assets
  static("/samples/sockets/public")
  port(8888)

  let conf = map[
    ["extends", "org.java_websocket.server.WebSocketServer"],
    ["implements", map[
      ["onOpen", |this, conn, handshake| {
        this: sendToAll("new connection: "+ handshake: getResourceDescriptor())
        println("-->" + conn: getRemoteSocketAddress(): getAddress(): getHostAddress() + " entered the room!" )
        println(this: connections())

      }],
      ["onClose", |this, conn, code, reason, remote| {
        this: sendToAll(conn + " bye bye")
      }],
      ["onMessage", |this, con, message| {
        this: sendToAll(message)
      }],
      ["onError", |this, con, ex| {
        ex: printStackTrace()
      }]
    ]]
  ]
  let s = AdapterFabric()
    : maker(conf)
    : newInstance(java.net.InetSocketAddress(8887))

  s: start()
  println(s: getPort())

    GET("/about", |request, response| {
      response:type("application/json")
      return Json(): toJsonString(map[["websockets_with", "https://github.com/TooTallNate/Java-WebSocket"]])
    })

}

