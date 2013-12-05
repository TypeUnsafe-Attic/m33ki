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
    |message, self| {
      self: result("wait")
      println("You've got a message : " + message)
      let r = result(0)
      5: times({
        r: value(r: value() + 1)
        println(r: value())

        java.lang.Thread.sleep(1000_L)

        #println(java.util.Date(): toString())
      })
      self: result("Result : " + r: value())
    })


  GET("/future", |request, response| {
    response:type("application/json")
    futureSum: submit("hello")
    response: status(200) # 200: OK
    return Json(): message("future is coming")

  })

  # Retrieve result of the future
  GET("/resfuture", |request, response| {
    response:type("application/json")
    response: status(200) # 200: OK

    try {
      let res = futureSum: result()
      println(res)
      return Json(): message(res)
    } catch(e) {
      return Json(): message(e)
    }

  })




}

