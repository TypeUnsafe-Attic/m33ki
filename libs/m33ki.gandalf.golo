module m33ki.gandalf

import m33ki.spark
import m33ki.jackson
import m33ki.models
import m33ki.collections

#wip

function CRUD = |collections| {

  # Create a model
  POST("/:kind", |request, response| {
    let collection = collections: get(request: params(":kind"))
    if collection isnt null {
      response:type("application/json")
      let model = Model(): fromJsonString(request: body())
      model: generateId()
      collection: addItem(model)
      response: status(201) # 201: created
      return model: toJsonString()
    } else {
      response: status(500) #
      return Json(): message("Huston, we've got a problem")
    }
  })

  # Retrieve all models
  GET("/:kind", |request, response| {
    let collection = collections: get(request: params(":kind"))
    if collection isnt null {
      response:type("application/json")
      return collection: toJsonString()
    } else {
      response: status(500) #
      return Json(): message("Huston, we've got a problem")
    }
  })

  # Retrieve a human by id
  GET("/:kind/:id", |request, response| {
    let collection = collections: get(request: params(":kind"))
    if collection isnt null {
      response:type("application/json")
      let model = collection: getItem(request: params(":id"))
      if model isnt null{
        return model: toJsonString()
      } else {
        response: status(404) # 404 Not found
        return Json(): toJsonString(map[["message", "Model not found"]])
      }
    } else {
      response: status(500) #
      return Json(): message("Huston, we've got a problem")
    }
  })

  PUT("/:kind/:id", |request, response| {

    let collection = collections: get(request: params(":kind"))
    if collection isnt null {
      response:type("application/json")
      let model = Model(): fromJsonString(request: body())
      #model: generateId()
      collection: addItem(model)
      #TODO verify code ie:202 ?
      response: status(201) # 201: updated
      return model: toJsonString()
    } else {
      response: status(500) #
      return Json(): message("Huston, we've got a problem")
    }
  })

  DELETE("/kind/:id", |request, response| {

    let collection = collections: get(request: params(":kind"))
    if collection isnt null {
      response:type("application/json")
      let model = collection: removeItem(request: params(":id"))

      #WARNING : with mongo delete is a method of the model
      #TODO ...

      if model isnt null{
        #return model: toJsonString()
        return Json(): message(request: params(":id") + " has been deleted")
      } else {
        response: status(404) # 404 Not found
        return Json(): toJsonString(map[["message", "Model not found"]])
      }
    } else {
      response: status(500) #
      return Json(): message("Huston, we've got a problem")
    }

  })
}