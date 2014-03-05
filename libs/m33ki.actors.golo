module m33ki.actors

import hopes

struct actorStructure = {
  executor,
  mailbox,
  onReceiveCallBack,
  listening,
  delay
}

augment m33ki.actors.types.actorStructure {

  function onReceive = |this, onReceiveCallBack| {
    # contract
    require(isClosure(onReceiveCallBack) is true, "onReceiveCallBack must be a Closure")
    # end of contract
    this: onReceiveCallBack(onReceiveCallBack)
    return this
  }

  function tell = |this, message| {
    this: mailbox(): offer(message)
    return this
  }

  function stop = |this| {
    this: tell("stop")
    return this
  }
  # to do : whenStop()
  function start = |this| {
    let delay =  this?: delay() orIfNull 100_L
    let actor_hope = Hope(this: executor())
      : todo(|value| { # value is set with go() method
          this: listening(true)

          while this: listening() is true {
            if this: mailbox(): size() > 0  { # you've got a mail
              let message = this: mailbox(): poll()
              if message: equals("stop") isnt true {
                this: onReceiveCallBack()(message, this)
              } else {
                this: listening(false)
              }
            }
            java.lang.Thread.sleep(delay)
          }
          return null
      })
      : done(|value| { # always = null
          #println("actor stops listening")
      })
      : go(null)
    return this
  }
}

function Actor = |executor| {
  require(executor oftype java.util.concurrent.ExecutorService.class, "executor must be an ExecutorService")
  let actor = actorStructure()
  actor
    : executor(executor)
    : mailbox(java.util.concurrent.ConcurrentLinkedQueue())
    : listening(false)
  return actor
}
