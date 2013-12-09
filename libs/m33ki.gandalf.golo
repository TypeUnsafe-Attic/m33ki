module m33ki.gandalf

import m33ki.spark
import m33ki.jackson
import m33ki.models
import m33ki.collections

import m33ki.authentication

#wip
#TODO: search

----
> Arguments :
>> collections : type : `map[["collection_name", collection]]`,
>> - `collection_name` is a string, it will be the first part of the REST url
>> - `collection` is a M33ki collection see : `m33ki.collections`, `m33ki.mongodb`

http://developer.yahoo.com/social/rest_api_guide/http-response-codes.html

http://yobriefca.se/blog/2012/03/20/tinkering-with-spark-a-micro-web-framework-for-java/
search about filter
----
function CRUD = |collections| {

  # --- SECURITY ---
  var SECURED = false
  let users = collections: get("users")
  if users isnt null {
    AUTHENTICATION(users)
    ADMIN(users)
    SECURED = true
  }

  collections: filter(|key, collection| { return not key: equals("users") }): each(|key, collection| {
    println(key+" "+collection)

    case {
      when collection: kind(): equals("memory") {
        ########################################
        # --- Memory Collections ---
        ########################################

        # Create a model
        POST("/"+key, |request, response| {

          if (SECURED is false) or (Session(request): create() is true) {

            let collection = collections: get(key)
            response: type("application/json")

            if collection isnt null {
              let model = Model(): fromJsonString(request: body())
              model: generateId()
              collection: addItem(model)
              response: status(201) # 201: created
              return model: toJsonString()
            } else {
              println("500")
              response: status(500) #
              return Json(): message("Huston, we've got a problem")
            }

          } else {
            println("403")
            response: status(403) # forbidden
            return Json(): toJsonString(map[["message", "insufficient rights"]])
          }

        })

        # Retrieve all models
        GET("/"+key, |request, response| {
          let collection = collections: get(key)
          response: type("application/json")

          if collection isnt null {
            response: status(200)
            return collection: toJsonString()
          } else {
            response: status(500) #
            return Json(): message("Huston, we've got a problem")
          }
        })

        # Retrieve a model by id
        GET("/"+key+"/:id", |request, response| {
          let collection = collections: get(key)
          response: type("application/json")

          if collection isnt null {
            let model = collection: getItem(request: params(":id"))

            if model isnt null {
              response: status(200)
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

        #search find(|this, fieldName, value|
        GET("/"+key+"/find/:fieldName/:value", |request, response| {
          let collection = collections: get(key)
          response: type("application/json")
          if collection isnt null {
            response: status(200)
            return  collection: find(request: params(":fieldName"), request: params(":value")): toJsonString()
          } else {
            response: status(500) #
            return Json(): message("Huston, we've got a problem")
          }

        })

        # Update model
        PUT("/"+key+"/:id", |request, response| {

          if (SECURED is false) or (Session(request): update() is true) {

            let collection = collections: get(key)
            response:type("application/json")

            if collection isnt null {
              let model = Model(): fromJsonString(request: body())
              model: setField("id", request: params(":id"))
              collection: addItem(model)
              response: status(200)
              return model: toJsonString()
            } else {
              response: status(500) #
              return Json(): message("Huston, we've got a problem")
            }

          } else {
            response: status(403) # forbidden
            return Json(): toJsonString(map[["message", "insufficient rights"]])
          }

        })


        DELETE("/"+key+"/:id", |request, response| {

          if (SECURED is false) or (Session(request): delete() is true) {

            let collection = collections: get(key)
            response:type("application/json")

            if collection isnt null {
              let model = collection: removeItem(request: params(":id"))
              #WARNING : with mongo delete is a method of the model
              #TODO ...
              if model isnt null{
                #return model: toJsonString()
                response: status(200)
                return Json(): message(request: params(":id") + " has been deleted")
              } else {
                response: status(404) # 404 Not found
                return Json(): toJsonString(map[["message", "Model not found"]])
              }

            } else {
              response: status(500) #
              return Json(): message("Huston, we've got a problem")
            }

          } else {
            response: status(403) # forbidden
            return Json(): toJsonString(map[["message", "insufficient rights"]])
          }


        })

      } # end when / memory
      when collection: kind(): equals("mongodb") {

        ########################################
        # --- MongoDB Collections ---
        ########################################

        # Create a mongo model
        POST("/"+key, |request, response| {

          if (SECURED is false) or (Session(request): create() is true) {

            let collection = collections: get(key)
            response: type("application/json")

            if collection isnt null {
              let model = collection: model(): fromJsonString(request: body())
              model: create() # insert in collection
              response: status(201) # 201: created
              return model: toJsonString()
            } else {
              response: status(500) #
              return Json(): message("Huston, we've got a problem")
            }

          } else {
            response: status(403) # forbidden
            return Json(): toJsonString(map[["message", "insufficient rights"]])
          }

        })

        # Retrieve all mongo models
        GET("/"+key, |request, response| {
          let collection = collections: get(key)
          response: type("application/json")
          if collection isnt null {
            response: status(200)
            return collection: fetch(): toJsonString()
          } else {
            response: status(500) #
            return Json(): message("Huston, we've got a problem")
          }
        })

        # Retrieve a mongo model by id
        GET("/"+key+"/:id", |request, response| {
          let collection = collections: get(key)
          response: type("application/json")

          if collection isnt null {
            let model = collection: model(): fetch(request: params(":id"))
            if model isnt null{
              response: status(200)
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

        #search find(|this, fieldName, value|
        GET("/"+key+"/find/:fieldName/:value", |request, response| {
          let collection = collections: get(key)
          response: type("application/json")
          if collection isnt null {
            response: status(200)
            return  collection: find(request: params(":fieldName"), request: params(":value")): toJsonString()
          } else {
            response: status(500) #
            return Json(): message("Huston, we've got a problem")
          }

        })

        #TODO:to be tested
        PUT("/"+key+"/:id", |request, response| {

          if (SECURED is false) or (Session(request): update() is true) {

            let collection = collections: get(key)
            response: type("application/json")

            if collection isnt null {
              response: status(200)
              let model = collection: model(): fromJsonString(request: body())
              model: update()
              return model: toJsonString()
            } else {
              response: status(500) #
              return Json(): message("Huston, we've got a problem")
            }

          } else {
            response: status(403) # forbidden
            return Json(): toJsonString(map[["message", "insufficient rights"]])
          }

        })


        DELETE("/"+key+"/:id", |request, response| {

          if (SECURED is false) or (Session(request): delete() is true) {

            let collection = collections: get(key)
            response: type("application/json")

            if collection isnt null {
              response: status(200)
              let model = collection: model(): delete(request: params(":id"))
              return Json(): message(request: params(":id") + " has been deleted")
            } else {
              response: status(500) #
              return Json(): message("Huston, we've got a problem")
            }

          } else {
            response: status(403) # forbidden
            return Json(): toJsonString(map[["message", "insufficient rights"]])
          }

        })

      } # end when / mongoDB
      when collection: kind(): equals("redis") { # --- Redis Collections ---
        #TODO
      } # end when
      otherwise {
        #TODO: raise(something)
      } # end when

    } # end otherwise
  }) # end collections:each

} # end function CRUD