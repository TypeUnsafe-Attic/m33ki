module m33ki.authentication

import m33ki.spark
import m33ki.jackson
import m33ki.models
import m33ki.collections

function Session = |request| {
  let session = request: session(true)
  return DynamicObject()
    : pseudo(session: attribute("pseudo"))
    : read(session: attribute("read"))
    : create(session: attribute("create"))
    : update(session: attribute("update"))
    : delete(session: attribute("delete"))
    : admin(session: attribute("admin"))
}

function User = {

  return Model()
    : setField("id", "JohnDoe") # this is the pseudo
    : setField("firstName", "John")
    : setField("lastName", "Doe")
    : setField("password", null)
    : setField("read", true)
    : setField("create", false)
    : setField("update", false)
    : setField("delete", false)
    : setField("admin", false)
    : define("rights", |this, canRead, canCreate, canUpdate, canDelete|{
        this: setField("read", canRead)
        this: setField("create", canCreate)
        this: setField("update", canUpdate)
        this: setField("delete", canDelete)
        return this
      })
    : define("pseudo", |this, pseudo|{
        this: setField("id", pseudo)
        return this
      })
    : define("pwd", |this, password|{
        this: setField("password", password)
        return this
      })
    : define("admin", |this, isAdmin|{
        this: setField("admin", isAdmin)
        return this
    })
    : define("isAdmin", |this|{
        return this: getField("admin")
    })

}

function AUTHENTICATION = |users| {

  #TODO: test id users: kind("memory") is true

  # Login
  #$.ajax({
  #	type: "POST",
  #	url: "login",
  #	data: JSON.stringify({pseudo:"admin", password:"admin"}),
  #	success: function(data){ console.log("success", data); },
  #	error: function(err){ console.log("error", err); },
  #	dataType: "json"
  #});
  POST("/login", |request, response| {
    response:type("application/json")
    let tmpUser = Model(): fromJsonString(request: body())
    let searchUser = users: getItem(tmpUser: getField("pseudo"))

    let session = request: session(true)

    if searchUser isnt null {
      if searchUser: getField("password"): equals(tmpUser: getField("password")) {
        response: status(200) # OK

        session: attribute("pseudo",  searchUser: getField("id"))
        session: attribute("read",    searchUser: getField("read"))
        session: attribute("create",  searchUser: getField("create"))
        session: attribute("update",  searchUser: getField("update"))
        session: attribute("delete",  searchUser: getField("delete"))
        session: attribute("admin",   searchUser: getField("admin"))

        return Json(): toJsonString(map[["authenticated", true]])
      } else {

        session: removeAttribute("pseudo")
        session: removeAttribute("read")
        session: removeAttribute("create")
        session: removeAttribute("update")
        session: removeAttribute("delete")
        session: removeAttribute("admin")

        response: status(403) # forbidden
        return Json(): toJsonString(map[["authenticated", false]])
      }
    } else {

      session: removeAttribute("pseudo")
      session: removeAttribute("read")
      session: removeAttribute("create")
      session: removeAttribute("update")
      session: removeAttribute("delete")
      session: removeAttribute("admin")

      response: status(403) # forbidden
      return Json(): toJsonString(map[["authenticated", false]])
    }

  })

  # is current user authenticated
  # $.get("authenticated", function(data){ console.log(data); })
  GET("/authenticated", |request, response| {
    response:type("application/json")

    let session = request: session(true)

    if session: attribute("pseudo") isnt null {
      response: status(200) # OK
      return Json(): toJsonString(map[["authenticated", true]])
    } else {
      response: status(200) # OK
      return Json(): toJsonString(map[["authenticated", false]])
    }
  })

  # Logout
  GET("/logout", |request, response| {
    response:type("application/json")
    let session = request: session()

    session: removeAttribute("pseudo")
    session: removeAttribute("read")
    session: removeAttribute("create")
    session: removeAttribute("update")
    session: removeAttribute("delete")
    session: removeAttribute("admin")

    return Json(): toJsonString(map[["authenticated", false]])
  })

}

function ADMIN = |users| {
  #TODO: test id users: kind("memory") is true

  ########################################
  # --- Memory Collections ---
  ########################################

  # Create a model
  POST("/users", |request, response| {

    if Session(request): admin() is true {

      let collection = users
      response: type("application/json")

      if collection isnt null {
        let model = Model(): fromJsonString(request: body())
        #model: generateId()
        # pseudo = id
        if model: getField("pseudo") isnt null { model: setField("id", model: getField("pseudo")) }

        collection: addItem(model)
        #TODO: verify if already exists

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
  GET("/users", |request, response| {

    if Session(request): admin() is true {

      let collection = users
      response: type("application/json")

      if collection isnt null {
        response: status(200)
        return collection: toJsonString()
      } else {
        response: status(500) #
        return Json(): message("Huston, we've got a problem")
      }

    } else {
      response: status(403) # forbidden
      return Json(): toJsonString(map[["message", "insufficient rights"]])
    }

  })

  # Retrieve a model by id
  GET("/users/:id", |request, response| {

    if Session(request): admin() is true {

      let collection = users
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

    } else {
      response: status(403) # forbidden
      return Json(): toJsonString(map[["message", "insufficient rights"]])
    }

  })

  # Update model
  PUT("/users/:id", |request, response| {

    if Session(request): admin() is true {
      let collection = users
      response:type("application/json")

      if collection isnt null {
        let model = Model(): fromJsonString(request: body())
        #model: generateId()
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

  DELETE("/users/:id", |request, response| {

    if Session(request): admin() is true {

      let collection = users
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

}

