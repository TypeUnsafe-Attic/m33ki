module using_futures

import m33ki.spark
import m33ki.jackson
import m33ki.futures

struct result = { value }

function main = |args| {

  # static assets
  static("/samples/futures/public")
  port(8888)

  let executor = getExecutor()

  let futureSum = Future(executor,
    |message| {
      println("You've got a message : " + message)
      let r = result(0)
      5: times({
        r: value(r: value() + 1)
        println(r: value())
        #println(java.util.Date(): toString())
      })
      return r
    })


  GET("/future", |request, response| {
    response:type("application/json")
    futureSum: submit("hello")
    response: status(200) # 200: OK
    return Json(): message("message", "future is coming")
  })

  # Retrieve all humans
  GET("/resfuture", |request, response| {
    response:type("application/json")
    return Json(): message("result", futureSum: getResult(): value())
  })

}

