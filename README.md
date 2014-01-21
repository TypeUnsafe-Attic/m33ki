#M33ki

>>The !(not)Opinionated Web Framework

*M33ki Framework makes it easy to build web applications with Golo & Java.*

M33ki is based on a lightweight, stateless or stateful (as you want) , web-friendly architecture.

Built on Golo and SparkJava *(and some other libraries)*, M33ki provides minimal resource consumption (CPU, memory, threads) for embedded web server.

##Developer friendly.

Make your changes and simply hit refresh! All you need is a browser and a text editor.

###Getting started with Golo

![...](appgolo.gif)

###Getting started with Java

![...](appjava.gif)

##Asynchronous model ... if you want

###Futures

```coffeescript
let future = Future(executor, |message, self| {
    self: result(0)
    println("You've got a message : " + message)
    42: times({
      self: result(self: result() + 1)
      java.lang.Thread.sleep(1000_L)
    })
    println(self: result())
  })
```

###Promises

```coffeescript
var result = DynamicObject(): value(0)

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
  : success(|value| { # if success
      println("success : " + value)
      result: value(value)
  })
  : error(|error| { # on error
      println("error : " + error)
  })
  : always(|self| { # but always
      println("always : " + self: result())
  })
  : make(5) # arg
```

###Observers

```coffeescript
let dyno = DynamicObject(): info(""): total(0)

let observer = Observer(executor)
  : observable(dyno): delay(3000_L)
  : onChange(|currentValue, oldValue, thatObserver| {

      println("old : " + oldValue: info() + " " + oldValue: total())
      println("current : " + currentValue: info() + " " + currentValue: total())

    })
  : observe(["info", "total"])
```

##Modern web & mobile.

M33ki was built for needs of modern web & mobile apps.

- RESTful by default
- JSON is a first class citizen
- Websockets, EventSource (Server Sent Events)
- NoSQL (MongoDb & Redis)

###Example

```coffeescript
  # Create a model
  POST("/models", |request, response| {
    response: type("application/json")
    println(request: body())
    response: status(201) # 201: created
    return Json(): toJsonString(map[["message", "this is a POST request"]])
  })

# Retrieve all models
GET("/models", |request, response| {
  response: type("application/json")
  return Json(): toJsonString(map[["message", "this is a GET request"]])
})

# Retrieve a model by id
GET("/models/:id", |request, response| {
  response: type("application/json")
  let id = request: params(":id")
  return Json(): toJsonString(map[["message", "this is a GET request with id="+id]])
})

# Update model
PUT("/models/:id", |request, response| {
  response: type("application/json")
  println(request: body())
  let id = request: params(":id")
  return Json(): toJsonString(map[["message", "this is a PUT request with id="+id]])
})

# Delete model
DELETE("/models/:id", |request, response| {
  response: type("application/json")
  let id = request: params(":id")
  return Json(): toJsonString(map[["message", "this is a DELETE request with id="+id]])
})
```

##Install M33ki

###Dependencies

###Linux


###OSX


###Windows


##Extend your application


##Extend M33ki

###Jars

###Templates


##W.I.P.

- Documentation
- Front framework
- Generators




