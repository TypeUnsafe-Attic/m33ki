module m33ki.websockets

import m33ki.jackson

augment org.java_websocket.server.WebSocketServer {
  function sendToAll = |this, text| {
    let con = this: connections()
    #println(text)
    let semaphore = java.util.concurrent.Semaphore(1)
    semaphore: acquire()
    con: each(|cx|{ cx: send(text) })
    semaphore: release()
  }
}

function WSocket = |port| {

  let dynServer = DynamicObject()

  let conf = map[
    ["extends", "org.java_websocket.server.WebSocketServer"],
    ["implements", map[
      ["onOpen", |this, connection, handshake| {
        dynServer: _onOpen(connection, handshake)
      }],
      ["onClose", |this, connection, code, reason, remote| {
        dynServer: _onClose(connection, code, reason, remote)
      }],
      ["onMessage", |this, connection, message| {
        dynServer: _onMessage(connection, message)
      }],
      ["onError", |this, connection, ex| {
        dynServer: _onError(connection, ex)
      }]
    ]]
  ]
  let server = AdapterFabric()
    : maker(conf)
    : newInstance(java.net.InetSocketAddress(port))

  dynServer
    : server(server)
    : connections(map[])
    : define("sendToAll",|this, message| {
        this: server(): sendToAll(message)
        return this
      })
    : define("start", |this| {
        server: start()
        return this
      })
    : define("stop", |this| {
        server: stop()
        return this
      })
    : define("port", |this| {
        return server: getPort()
      })
    : define("sendTo", |this, dynConn, message| {
        #println("==" + message + "==")
        dynConn: socketConnection(): send(message)
        return this
      })
    : define("_onOpen", |this, connection, handshake|{
        let uid = java.util.UUID.randomUUID(): toString()
        let dynConn = DynamicObject(): socketConnection(connection): uid(uid)
        this: connections(): add(connection, dynConn)
        connection: send(Json(): toJsonString(map[["uid", uid]]))
        this: onOpen(dynConn)
      })
    : define("onOpen", |this, dynConn| {
        # foo
        #println(dynConn: uid() + " connected : " + dynConn: socketConnection(): getRemoteSocketAddress(): getAddress(): getHostAddress())
      })
    : define("_onClose", |this, connection, code, reason, remote|{
        this: onClose(this: connections(): get(connection))
        this: connections(): remove(connection)
      })
    : define("onClose", |this, dynConn| {
        # foo
        #this: sendToAll(dynConn: uid() + " has exit.")
      })
    : define("_onMessage", |this, connection, message|{
        this: onMessage(this: connections(): get(connection), message)
      })
    : define("onMessage", |this, dynConn, message| {
        # foo
        #println(">=->> " + dynConn: uid() + " : " + message )
        #this: sendToAll(message)
      })
    : define("_onError", |this, connection, exception|{
        this: onError(this: connections(): get(connection), exception)
        exception: printStackTrace()
      })
    : define("onError", |this, dynConn, exception| {
        # foo
      })

  return dynServer
}