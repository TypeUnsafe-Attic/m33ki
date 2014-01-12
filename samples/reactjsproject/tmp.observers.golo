



# helpers
import m33ki.observers              #let executor = getExecutor()
import m33ki.valueobjects
import m33ki.strings


  let executor = getExecutor()      # needed by observers

  # === experimental ===
  let a = ValueObject(0)
  let obs1 = Observer(executor)
    : observable(a)
    : onChange(|currentValue, oldValue, thatObserver| {
        let data = [currentValue, oldValue]
        println(
          """
          ValueObject A has changed,
            old : <%= data: get(1) %>,
            new : <%= data: get(0) %>
          """:
          T("data", data)
        )
      })
    : observe()

  let dyno = DynamicObject(): info(""): total(0)

  let obs2 = Observer(executor)
    : observable(dyno): delay(3000_L)
    : onChange(|currentValue, oldValue, thatObserver| {

        let data = [currentValue, oldValue]
        println(
          """
          DynamicObject DYNO has changed,
            old : <%= data: get(1): info() %> | <%= data: get(1): total() %>,
            new : <%= data: get(0): info() %> | <%= data: get(0): total() %>
          """:
          T("data", data)
        )
      })
    : observe(["info", "total"])
  # === end of experimental ===


  # === experimental ===
  GET("/change_a", |request, response| {
    response:type("application/json")
    a: increment()
    response: status(200)
    return Json(): toJsonString(map[["a", a: value()]])
  })

  GET("/change_dyno", |request, response| {
    response:type("application/json")
    dyno: info("Hello num : " + dyno: total()): total(dyno: total() + 1)
    response: status(200)
    return Json(): toJsonString(map[ ["info", dyno: info()], ["total", dyno: total()] ])
  })