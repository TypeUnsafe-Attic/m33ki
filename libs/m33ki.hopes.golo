module m33ki.hopes

import gololang.Async
import java.util.concurrent.TimeUnit
import java.util.concurrent.Executors
import java.util.concurrent.Semaphore

function getExecutor = -> Executors.newCachedThreadPool()

augment java.util.concurrent.Semaphore {
  function protect = |this, somethingToCompute| { #restrict
    this: acquire()
    somethingToCompute()
    this: release()
  }
}

function getSemaphore = |arg| -> java.util.concurrent.Semaphore(arg)

# Properties
struct hopeStructure = {
    promise
  , task
  , executor
}
# Methods
augment m33ki.hopes.types.hopeStructure {

  function todo = |this, task2run| { # this is a setter
    this: task(task2run)
    return this
  }

  function done = |this, callbackWhenDone| { # this is a setter
    this: promise(): future(): onSet(callbackWhenDone)
    return this
  }

  function go = |this, value| {
    this: executor(): submit({
      this: promise(): set(this: task()(value))
    })
    return this
  }

}
# Constructor
function Hope = |executor| {
  return hopeStructure(promise(), null, executor)
}

