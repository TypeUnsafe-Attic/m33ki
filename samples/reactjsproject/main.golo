module main

import m33ki.spark
import m33ki.jackson
import m33ki.hot # requisite for "hot reloading"

import m33ki.observers
import m33ki.valueobjects
import m33ki.strings

# see /app/application.golo
import application


function main = |args| {
  let executor = getExecutor()

  initialize(): static("/public"): port(8888): error(true)
    : listenForChange("") # listen to root of the webapp

  let a = ValueObject(0)
  let b = ValueObject(0)

  let obs1 = Observer(executor)
    : observable(a)
    : onChange(|currentValue, oldValue, thatObserver| {
        let data = [currentValue, oldValue]
        println(
          """
          ValueObject A has changed,
            old : <%= data: get(1) %>,
            new : <%= data: get(0) %>
          """: T("data", data)
        )
      })
    : observe()

  let obs2 = Observer(executor)
    : observable(b)
    : onChange(|currentValue, oldValue, thatObserver| {
        let data = [currentValue, oldValue]
        println(
          """ValueObject B has changed, old : <%= data: get(1) %>, new : <%= data: get(0) %>""": T("data", data)
        )
      })
    : observe()

  let obs3 = Observer(executor)
    : observable(a)
    : onChange(|currentValue, oldValue, thatObserver| {
        let data = [currentValue, oldValue]
        println("I'm an other observer, A has change")
      })
    : observe()

  GET("/change_a", |request, response| {
    response:type("application/json")
    a: increment()
    response: status(200)
    return Json(): toJsonString(map[["a", a: value()]])
  })

  GET("/change_b", |request, response| {
    response:type("application/json")
    b: increment()
    response: status(200)
    return Json(): toJsonString(map[["b", b: value()]])
  })

  GET("/kill_observer", |request, response| {
    response:type("application/json")
    obs3: kill()
    response: status(200)
    return Json(): toJsonString(map[["message", "obs3 has been killed!"]])
  })

  # my first little json service
  GET("/about", |request, response| {
    response:type("application/json")
    response: status(200)
    return Json(): toJsonString(map[["message", "ReactJS project"]])
  })

}
