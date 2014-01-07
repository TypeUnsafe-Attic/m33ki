module m33ki.authentication

import m33ki.spark
import m33ki.jackson
import m33ki.models
import m33ki.collections

import org.jasypt.encryption.pbe.StandardPBEStringEncryptor

#TODO
#function getSecurityKey = -> "ultimatelanguageisgolo"

function encrypt = |something, withSecurityKey| {
  let encryptor = StandardPBEStringEncryptor()
  encryptor: setPassword(withSecurityKey)
  let encryptedValue = encryptor: encrypt(something)
  println("Encryption done and encrypted value is : " + encryptedValue )
  return encryptedValue
}

function decrypt = |something, withSecurityKey| {
  let encryptor = StandardPBEStringEncryptor()
  encryptor: setPassword(withSecurityKey)
  let decryptedValue = encryptor: decrypt(something)
  println(decryptedValue)
  return decryptedValue
}

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

# Generic User
function User = {

  return Model()
    : setField("pseudo", "john")
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
    : define("canRead", |this, can|{
        this: setField("read", can)
        return this
      })
    : define("canCreate", |this, can|{
        this: setField("create", can)
        return this
      })
    : define("canUpdate", |this, can|{
        this: setField("update", can)
        return this
      })
    : define("canDelete", |this, can|{
        this: setField("delete", can)
        return this
      })
    : define("pseudo", |this, pseudo|{
        this: setField("pseudo", pseudo)
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


function AUTHENTICATION = |users, securityKey| {

  println("--- Define Authentication routes ---")

  # Login
  #$.ajax({
  #	type: "POST",
  #	url: "login",
  #	data: JSON.stringify({pseudo:"admin", password:"admin"}),
  #	success: function(data){ console.log("success", data); },
  #	error: function(err){ console.log("error", err); },
  #	dataType: "json"
  #});
  # OK for memory Users and mongoDb USers
  POST("/login", |request, response| {
    println("--> authentication attempt")
    response:type("application/json")
    let tmpUser = Model(): fromJsonString(request: body())

    println("--> user : " + tmpUser)
    println("--> user.pseudo : " + tmpUser: getField("pseudo"))
    println("--> users :" + users: models())

    # if memory collection
    let searchUser = users: find("pseudo", tmpUser: getField("pseudo")): toModelsList(): getFirst()

    println("--> searchUser : " + searchUser: getField("pseudo") )

    let session = request: session(true)

    if searchUser isnt null {

      if decrypt(searchUser: getField("password"), securityKey): equals(tmpUser: getField("password")) {
        response: status(200) # OK

        session: attribute("pseudo",  searchUser: getField("pseudo"))
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

function ADMIN = |users, securityKey| {
  #TODO: test id users: kind("memory") is true

  case {
    when users: kind(): equals("memory") {
      ########################################
      # --- Memory Collections ---
      ########################################

      # Create a user
      POST("/users", |request, response| {

        if Session(request): admin() is true {

          let collection = users
          response: type("application/json")

          if collection isnt null {
            let model = Model(): fromJsonString(request: body())
            model: generateId()
            # pseudo = id

            # encrypt password
            let pwd = model: getField("password")
            model: setField("password", encrypt(pwd, securityKey))

            println(model: toJsonString())

            #if model: getField("pseudo") isnt null { model: setField("pseudo", model: getField("pseudo")) }

            collection: addItem(model)
            #TODO: verify if already exists

            response: status(201) # 201: created
            return model: toJsonString() #becareful : password ?!!! display
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

      # Retrieve a model by pseudo
      GET("/users/pseudo/:pseudo", |request, response| {

        if Session(request): admin() is true {

          let collection = users
          response: type("application/json")

          if collection isnt null {

            let models = users: find("pseudo", request: params(":pseudo")): toModelsList()

            let model = models: getFirst()

            if model isnt null {
              response: status(200)
              return model: toJsonString()
            } else {
              response: status(404) # 404 Not found
              return Json(): toJsonString(map[["message", "User not found"]])
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
      # TODO : Password ???
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

    } # end when / memory
    when users: kind(): equals("mongodb") {

        ########################################
        # --- MongoDB Collections ---
        ########################################

        # Create a mongo user
        POST("/users", |request, response| {

          if Session(request): admin() is true {

            let collection = users
            response: type("application/json")

            if collection isnt null {
              let model = collection: model(): fromJsonString(request: body())
              #TODO: verify if already exists

              # encrypt password
              let pwd = model: getField("password")
              model: setField("password", encrypt(pwd, securityKey))

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

        # Retrieve all mongo users
        GET("/users", |request, response| {
          if Session(request): admin() is true {
            let collection = users
            response: type("application/json")
            if collection isnt null {
              response: status(200)
              return collection: fetch(): toJsonString()
            } else {
              response: status(500) #
              return Json(): message("Huston, we've got a problem")
            }
          } else {
            response: status(403) # forbidden
            return Json(): toJsonString(map[["message", "insufficient rights"]])
          }

        })

        # Retrieve a mongo user by id
        GET("/users/:id", |request, response| {
          if Session(request): admin() is true {
            let collection = users
            response: type("application/json")

            if collection isnt null {
              let model = collection: model(): fetch(request: params(":id"))

              if model isnt null{
                response: status(200)
                return model: toJsonString()
              } else {
                response: status(404) # 404 Not found
                return Json(): toJsonString(map[["message", "User not found"]])
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

        # Retrieve a mongo user by pseudo
        GET("/users/pseudo/:pseudo", |request, response| {
          if Session(request): admin() is true {
            let collection = users
            response: type("application/json")
            if collection isnt null {
              response: status(200)
              let admin = collection: find("pseudo", request: params(":pseudo")): toModelsList(): getFirst()
              if admin isnt null{
                response: status(200)
                return admin: toJsonString()
              } else {
                response: status(404) # 404 Not found
                return Json(): toJsonString(map[["message", "User not found"]])
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

        # Update model TODO: to be tested
        #TODO: and password ???
        PUT("/users/:id", |request, response| {

          if Session(request): admin() is true {

            let collection = users
            response: type("application/json")

            if collection isnt null {
              response: status(200)
              let model = collection: model(): fromJsonString(request: body())

              #println("MODEL : " + model: toJsonString())

              model: setField("id", request: params(":id"))
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


        DELETE("/users/:id", |request, response| {

          if Session(request): admin() is true {

            let collection = users
            response: type("application/json")

            if collection isnt null {
              response: status(200)
              #TODO: if model not exist : try catch ?

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
    when users: kind(): equals("redis") { # --- Redis Collections ---
     #TODO
    } # end when
    otherwise {
     #TODO: raise(something)
    } # end when

  } # end otherwise


}

