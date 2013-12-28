module using_futures

import m33ki.spark
import m33ki.jackson
import m33ki.promises

struct result = { value }

function main = |args| {

  # static assets
  static("/samples/promises/public")
  port(8888)

  let executor = getExecutor()
  var result = DynamicObject(): value(0)

  GET("/promise", |request, response| {
    response:type("application/json")

    Promise(executor)
    : task(|arg| {
      println("promise argument is " + arg)
      let res = DynamicObject(): value(1)

      arg: times(|index| {
        res: value(res: value() * (index + 1))
        java.lang.Thread.sleep(500_L)
      })

      return res: value()
    })
    : success(|value| { # success
        println("success : " + value)
        result: value(value)
    })
    : error(|error| { # error
        println("error : " + error)
    })
    : always(|self| { # always
        println("always : " + self: result())
    })
    : make(5) # arg

    response: status(200) # 200: OK
    return Json(): message("promise ignited")

  })

  GET("/resultpromise", |request, response| {
    response:type("application/json")
    response: status(200) # 200: OK
    return Json(): message(result: value())

   })

}

