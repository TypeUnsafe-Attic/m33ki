module m33ki

import m33ki.spark
import m33ki.jackson
import m33ki.models
import m33ki.collections
import m33ki.mongodb

#TODO: search query

function Book = -> DynamicObject()
  :mixin(Model())
  :mixin(MongoModel(Mongo(): database("golodb"): collection("books")))

function Books = -> DynamicObject()
  :mixin(Collection())
  :mixin(MongoCollection(Book()))


function main = |args| {

  let books = Books()

  #static("/public")
  static("/samples/books/public")
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
      return Json(): toJsonString(map[["message", "Book not found"]])
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

}

