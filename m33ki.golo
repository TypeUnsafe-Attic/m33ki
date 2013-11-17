module m33ki

import m33ki.spark
import m33ki.jackson
import m33ki.models
import m33ki.collections
import m33ki.mongodb

import m33ki.futures
import m33ki.sse

function Book = -> DynamicObject()
  :mixin(Model())
  :mixin(MongoModel(Mongo(): database("golodb"): collection("books")))

function Books = -> DynamicObject()
  :mixin(Collection())
  :mixin(MongoCollection(Book()))


function main = |args| {

  let books = Books()

  static("/public") 
  port(8888)

  # Create a book
  POST("/books", |request, response| {
    response:type("application/json")
    let book = Book(): fromJsonString(request: body())
    book: create() # insert in collection
    response: status(201) # 201: created
    return book: toJsonString()
  })

  # Retrieve all books
  GET("/books", |request, response| {
    response:type("application/json")
    return books: fetch(): toJsonString()
  })

  # Retrieve a book by id
  GET("/books/:id", |request, response| {
    response:type("application/json")

    let book = Book(): fetch(request: params(":id"))

    if book isnt null{
      return book: toJsonString()
    } else {
      response: status(404) # 404 Not found
      return Json(): message("message", "Book not found")
    }
  })

  PUT("/books/:id", |request, response| {
    response:type("application/json")
    let book = Book(): fromJsonString(request: body())  
    book: update()
    return book: toJsonString()
  }) 

  DELETE("/books/:id", |request, response| {
    response:type("application/json")
    let book = Book(): delete(request: params(":id"))
    return Json(): message(request: params(":id") + " has been deleted")
  })

  # How to call server sent events
  # (with jquery)
  #
  #  var source = new EventSource('/sse');
  #
  #  source.addEventListener('message', function(e) {
  #      console.log(e.data);
  #  }, false);
  #
  # ... source.close()


  # silly sample
  GET("/sse", |request, response| {
    let sse = ServerSourceEvent(): initialize(response)
    10: times({
        sse: write(java.util.Date(): toString())
        java.lang.Thread.sleep(1000_L)
    })
    sse: close()
  })

  let executor = getExecutor()
  GET("/future", |request, response| {
    Future(executor, |message| {
      10: times({
        println(java.util.Date(): toString())
      })
    }):submit(null)
  })


}

