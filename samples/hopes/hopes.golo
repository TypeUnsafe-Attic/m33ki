module hopes

import m33ki.spark
import m33ki.hopes
import m33ki.sse
import m33ki.jackson

import java.lang.Math

function piCalculus = |howManyIterations, sse| {
  var unQuartDePi = 0.0
  var pi = 0.0
  var k = 0.0

  let term = |k| ->(Math.pow(-1.0, k))/(2*k+1)
  for (var i = 0, i < howManyIterations, i = i + 1) {
      unQuartDePi = unQuartDePi + term(k)
      pi = 4 * unQuartDePi
      k=k+1.0
      sse: write(Json(): toJsonString(map[["value", i+" : "+pi]]))
      java.lang.Thread.sleep(50_L)
  }
  return pi
}

function main = |args| {

  initialize(): static("/samples/hopes/public"): port(8888): error(true)

  let iterations = DynamicObject(): value(10)

  GET("/pi", |request, response| {

    let sse = ServerSourceEvent(): initialize(response)

    let executor = getExecutor()

    let hope = Hope(executor)
      : todo(|value| {
          sse: write(Json(): toJsonString(map[["message", "pi computation started"]]))
          let pi =  piCalculus(value, sse)
          sse: write(Json(): toJsonString(map[["message", pi]]))
          sse: write(Json(): toJsonString(map[["message", "pi computation terminated"]]))
          return pi
      })
      : done(|result| {
        println("pi = " + result)
      })
      : go(iterations: value())

    iterations: value(iterations: value()+20)

    let pi = hope: promise(): blockingGet()

    sse: write(Json(): toJsonString(map[["message", "done"]]))
    sse: close()
    executor: shutdown()
  })

  # How to call server sent events
  #
  #  var source = new EventSource('/sse');
  #
  #  source.addEventListener('message', function(e) {
  #      console.log(e.data);
  #  }, false);
  #
  # ... source.close()

}

