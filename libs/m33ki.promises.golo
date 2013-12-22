module m33ki.promises

import m33ki.futures

# promises

function getExecutor = -> m33ki.futures.getExecutor()

struct optionsPromise = { arguments, success, error, always }

function isOptionsPromise = |options| -> options: members():equals(tuple["arguments", "success", "error", "always"])

function getPromise = |executor, task, options| {
  # contract
  require(executor oftype java.util.concurrent.ExecutorService.class, "executor must be an ExecutorService")
  require(isClosure(task) is true, "task must be a Closure")
  require(isOptionsPromise(options) , "options must be a m33ki.promises.types.optionsPromise")
  # end of contract

  return Future(
      executor
    , |params, self| {
      try {
        self: result(task(params))
        options: success()(self: result())
      } catch (e) {
        options: error()(e)
      } finally {
        options: always()(self)
      }
    }
  )
  : submit(options: arguments())
}

struct promise = { _executor, _task, _success, _error, _always }

augment m33ki.promises.types.promise {
  function executor = |this, executor| {
    # contract
    require(executor oftype java.util.concurrent.ExecutorService.class, "executor must be an ExecutorService")
    # end of contract
    this: _executor(executor)
    return this
  }
  function task = |this, task| {
    # contract
    require(isClosure(task) is true, "task must be a Closure")
    # end of contract
    this: _task(task)
    return this
  }
  function success = |this, success| {
    # contract
    require(isClosure(success) is true, "success must be a Closure")
    # end of contract
    this: _success(success)
    return this
  }
  function error = |this, error| {
    # contract
    require(isClosure(error) is true, "error must be a Closure")
    # end of contract
    this: _error(error)
    return this
  }
  function always = |this, always| {
    # contract
    require(isClosure(always) is true, "always must be a Closure")
    # end of contract
    this: _always(always)
    return this
  }
  function make = |this, arguments| {

    return getPromise(
        this: _executor()
      , this: _task()
      , optionsPromise()
      : arguments(arguments)
      : success(this: _success())
      : error(this: _error())
      : always(this: _always())
    )
  }
  function make = |this| {

    return getPromise(
        this: _executor()
      , this: _task()
      , optionsPromise()
        : arguments(null)
        : success(this: _success())
        : error(this: _error())
        : always(this: _always())
    )
  }
}

function Promise = |executor| {
  # contract
  require(executor oftype java.util.concurrent.ExecutorService.class, "executor must be an ExecutorService")
  # end contract
  return promise(): executor(executor)
}
