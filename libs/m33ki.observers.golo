module m33ki.observers

import m33ki.futures
import m33ki.valueobjects

function getExecutor = -> m33ki.futures.getExecutor()

# Observer structure
struct observer = { _executor, _observable, _onChange, future }

augment m33ki.observers.types.observer {
  function executor = |this, executor| {
    # contract
    require(executor oftype java.util.concurrent.ExecutorService.class, "executor must be an ExecutorService")
    # end of contract
    this: _executor(executor)
    return this
  }
  function onChange = |this, onChangeCallBack| {
    # contract
    require(isClosure(onChangeCallBack) is true, "onChangeCallBack must be a Closure")
    # end of contract
    this: _onChange(onChangeCallBack)
    return this
  }
  function observable = |this, observable| {
    require(observable: get("value") isnt null, "observable must have a 'value' property.")
    this: _observable(observable)
    return this
  }
  function observe = |this, delay| {
    let old_observable = ValueObject(this: _observable(): value())

    let observer_future = Future(this: _executor(), |message, self| {
      self: result(false) # don't forget that Future is a DynamicObject
      while self: result() is false {
        if this: _observable(): value(): equals(old_observable: value()) is false {
          try {
            this: _onChange()(this: _observable(), old_observable, self)
          } catch(e) {
            e: printStackTrace()
          }
          old_observable: value(this: _observable(): value())
        }
        java.lang.Thread.sleep(delay)
      }
      println("this is the end ...")
      self: result(true)
    })
    this: future(observer_future)
    observer_future: submit(null)
    return this
  }
  function observe = |this| {
    return this: observe(100_L)
  }
  function kill = |this| {
    this: future(): result(true)
    this: future(): cancel(true)
  }
}
----
# Observer

##Use, ie:

    let executor = getExecutor()
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

##Constructor `Observer(executor)`

Parameter: java.util.concurrent.ExecutorService.class

##Properties

- `observable()` : this is a DynamicObject, or a struct or a m33ki.valueobjects.ValueObject with a `value` member

##Methods

- `onChange(|currentValue, oldValue, thatObserver| {})` this is a callback closure, triggered when value of observable change
- `observe()`
- `observe(delay)` : delay unit is milliseconds, ie: `observe(500_L)`, default is `100_L` ms
- `kill()` : observer stops observes observable

----
function Observer = |executor| {
  require(executor oftype java.util.concurrent.ExecutorService.class, "executor must be an ExecutorService")
  return observer(): executor(executor)
}
