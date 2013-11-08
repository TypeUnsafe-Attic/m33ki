module spark_java

import m33ki.spark
import m33ki.jackson
import m33ki.models
import m33ki.collections

function Book = -> DynamicObject(): mixin(Model())
function Books = -> DynamicObject(): mixin(Collection())

function main = |args| {

  let books = Books()

  static("/public") 
  port(8888)

  POST("/books", |request, response| {
    response:type("application/json")
    let book = Book(): fromJsonString(request: body()): generateId()    
    books: addItem(book)
    response: status(201) # 201: created
    return book: toJsonString()
  })

  PUT("/books/:id", |request, response| {
    response:type("application/json")
    let book = Book(): fromJsonString(request: body())  
    # TODO: test if exists
    books: addItem(book) #update if exists
    return book: toJsonString()
  }) 

  GET("/books/:id", |request, response| {
    response:type("application/json")
    let book = books: getItem(request: params(":id"))

    if book isnt null{
      return book: toJsonString()
    } else {
      response: status(404) # 404 Not found
      return Json(): message("message", "Book not found")
    }
  })

  GET("/books", |request, response| {
    response:type("application/json")
    #return Json(): toJsonString(books: toList())
    return books: toJsonString()
  })

  DELETE("/books/:id", |request, response| {
    response:type("application/json")
    # TODO: test if exists
    let book = books: removeItem(request: params(":id"))
    return Json(): message(request: params(":id") + " has been deleted")
  })

}



