module m33ki.authentication

import m33ki.spark
import m33ki.jackson
import m33ki.models
import m33ki.collections

import org.jasypt.encryption.pbe.StandardPBEStringEncryptor

# encrypt
----
####Description

`encrypt(something, withSecurityKey)` function returns an encrypted string

####Parameters

- `something` : String to encrypt
- `withSecurityKey` : security key
----
function encrypt = |something, withSecurityKey| {
  let encryptor = StandardPBEStringEncryptor()
  encryptor: setPassword(withSecurityKey)
  let encryptedValue = encryptor: encrypt(something)
  println("Encryption done and encrypted value is : " + encryptedValue )
  return encryptedValue
}

# decrypt
----
####Description

`decrypt(something, withSecurityKey)` function returns a decrypted string

####Parameters

- `something` : String to decrypt
- `withSecurityKey` : security key
----
function decrypt = |something, withSecurityKey| {
  let encryptor = StandardPBEStringEncryptor()
  encryptor: setPassword(withSecurityKey)
  let decryptedValue = encryptor: decrypt(something)
  println(decryptedValue)
  return decryptedValue
}

# Session
----
####Description

`Session(req)` function returns a DynamicObject with properties of current session (Spark request: session()).

*Remark: if session object doesn't exist, it will be created*

####Parameter

You have to pass the Spark request object to `Session()` function

####Properties of Session DynamicObject

Each property of the DynamicObject is a session attribute :

- `id()`
- `pseudo()`
- `read()`
- `create()`
- `update()`
- `delete()`
- `admin()`

----
function Session = |request| {
  let session = request: session(true)
  return DynamicObject()
    : id(session: attribute("id"))
    : pseudo(session: attribute("pseudo"))
    : read(session: attribute("read"))
    : create(session: attribute("create"))
    : update(session: attribute("update"))
    : delete(session: attribute("delete"))
    : admin(session: attribute("admin"))
}

# Generic User
----
####Description

`User()` function returns a `m33ki.models.Model()` with default `fields(map[])` :

    map[
        ["pseudo", "john"]
      , ["firstName", "John"]
      , ["lastName", "Doe"]
      , ["password", null]
      , ["read", true]
      , ["create", false]
      , ["update", false]
      , ["delete", false]
      , ["admin", false]
    ]

####User Methods (+ Model methods)

- `rights(canRead, canCreate, canUpdate, canDelete)` : set fields values of `read, create, update, delete`

----
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

# AUTHENTICATION()
----
####Description

`AUTHENTICATION()` method is a helper about users authentication. It creates necessary REST routes about :

- user login
- user logout
- authentication user checking

####Parameters

- `users` : this is a `m33ki.collections.Collection()`. It can mixin a `m33ki.mongodb.MongoCollection(MongoModel)`
- `securityKey` : allow encrypt/decrypt user password
- `onLogin` : callback on user login : passing parameter : `user Model()` and `authenticated` (`true` or `false`)
- `onLogout` : callback on user logout : passing parameters : `user_id`, `user_pseudo`
- `ifAuthenticated` : callback on authentication checking : passing parameters : `user_id`, `user_pseudo` | `null` and `null` if failed

####Snippet

    AUTHENTICATION(
        AppUsers()
      , getSecurityKey()
      , |user, authenticated| { # on LogIn
          println(user: getField("pseudo") + " is authenticated : " + authenticated)
        }
      , |id, pseudo| { # on LogOut
          println(pseudo + "[" + id +  "] is gone ...")
        }
      , |id, pseudo| { # Authentication checking
          if id isnt null {
            println(pseudo +  " is online and authenticated ...")
          } else {
            println("Current user isn't authenticated ...")
          }
        }
    )

####Routes

If you're using `AUTHENTICATION` then you get 3 routes :

- `/login` to connect user (`POST` request)
- `/logout` (`GET` request)
- `/authenticated` to check if current user is connected (`GET` request)

#####Calling `/login` with jQuery (`$.ajax`)

    $.ajax({
      type: "POST",
      url: "login",
      data: JSON.stringify({pseudo:"admin", password:"admin"}),
      success: function(data){ console.log("success", data); },
      error: function(err){ console.log("error", err); },
      dataType: "json"
    });

#####Calling `/logout` with jQuery (`$.ajax`)

    $.get("authenticated", function(data){ console.log(data); })

    //return Object {authenticated: true} (or false) + pseudo if true (null if false)

#####Calling `/authenticated` with jQuery (`$.ajax`)

    $.get("logout", function(data){ console.log(data); })

----
function AUTHENTICATION = |users, securityKey, onLogin, onLogout, ifAuthenticated| {

  println("--- Define Authentication routes ---")

  # Login
  # OK for memory Users and mongoDb Users
  POST("/login", |request, response| {
    println("--> authentication attempt")
    response:type("application/json")
    let tmpUser = Model(): fromJsonString(request: body())

    println("--> user : " + tmpUser)
    println("--> user.pseudo : " + tmpUser: getField("pseudo"))
    println("--> users :" + users: models())

    #let searchUser = users: find("pseudo", tmpUser: getField("pseudo")): toModelsList(): getFirst()

    let searchUsers = users: find("pseudo", tmpUser: getField("pseudo"))
    let session = request: session(true)

    # searchUsers is a collection
    if searchUsers: size() > 0 {
      let searchUser = searchUsers: toModelsList(): getFirst()
      println("--> searchUser : " + searchUser: getField("pseudo") )
      println("--> searchUser : " + searchUser: getField("id") )


      if decrypt(searchUser: getField("password"), securityKey): equals(tmpUser: getField("password")) {
        response: status(200) # OK

        session: attribute("id",  searchUser: getField("id"))
        session: attribute("pseudo",  searchUser: getField("pseudo"))
        session: attribute("read",    searchUser: getField("read"))
        session: attribute("create",  searchUser: getField("create"))
        session: attribute("update",  searchUser: getField("update"))
        session: attribute("delete",  searchUser: getField("delete"))
        session: attribute("admin",   searchUser: getField("admin"))

        if onLogin isnt null {
          onLogin(searchUser, true)
        }

        return Json(): toJsonString(map[["authenticated", true]])

      } else {

        session: removeAttribute("id")
        session: removeAttribute("pseudo")
        session: removeAttribute("read")
        session: removeAttribute("create")
        session: removeAttribute("update")
        session: removeAttribute("delete")
        session: removeAttribute("admin")

        if onLogin isnt null {
          onLogin(tmpUser, false)
        }

        response: status(401) # not authenticated
        #response: status(403) # forbidden
        return Json(): toJsonString(map[["authenticated", false]])
      }

    } else  {


      session: removeAttribute("id")
      session: removeAttribute("pseudo")
      session: removeAttribute("read")
      session: removeAttribute("create")
      session: removeAttribute("update")
      session: removeAttribute("delete")
      session: removeAttribute("admin")

        if onLogin isnt null {
          onLogin(null)
        }

      response: status(401) # not authenticated
      #response: status(403) # forbidden
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

      if ifAuthenticated isnt null {
        ifAuthenticated(session: attribute("id"), session: attribute("pseudo"))
      }

      return Json(): toJsonString(map[["authenticated", true], ["pseudo", session: attribute("pseudo")]])
    } else {
      response: status(401) # not authenticated

      if ifAuthenticated isnt null {
        ifAuthenticated(null, null)
      }

      return Json(): toJsonString(map[["authenticated", false], ["pseudo", null]])
    }
  })

  # Logout
  GET("/logout", |request, response| {
    response:type("application/json")
    let session = request: session()

    if onLogout isnt null {
      onLogout(session: attribute("id"), session: attribute("pseudo"))
    }

    session: removeAttribute("id")
    session: removeAttribute("pseudo")
    session: removeAttribute("read")
    session: removeAttribute("create")
    session: removeAttribute("update")
    session: removeAttribute("delete")
    session: removeAttribute("admin")

    return Json(): toJsonString(map[["authenticated", false]])
  })

}

# ADMIN()
----
####Description

`ADMIN()` function is a quick helper to get REST routes about users management. It works with memory collections (`m33ki.collections.Collection()`) and MongoDb collections (`m33ki.mongodb.MongoCollection(MongoModel)`).

####Parameters

- `users` : this is a `m33ki.collections.Collection()`. It can mixin a `m33ki.mongodb.MongoCollection(MongoModel)`
- `securityKey` : allow encrypt/decrypt user password

####Routes

- Create user : this is a `POST` request : `/users`, you have to be login as admin
- Retrieve all users : this is a `GET` request : `/users`, you have to be login as admin
- Retrieve a user by id : this is a `GET` request : `/users/:id`, you have to be login as admin
- Retrieve a user by pseudo : this is a `GET` request : `/users/pseudo/:pseudo`, you have to be login as admin
- **(WIP:TO BE TESTED)** Update a user by id : this is a `PUT` request : `/users/:id`, you have to be login as admin
- Delete a user by id : this is a `DELETE` request : `/users/:id`, you have to be login as admin

####Calling Admin Routes with jQuery (`$.ajax`)

#####Create a user :

    $.ajax({
      type: "POST",
      url: "users",
      data: JSON.stringify({
          pseudo 		: "phil"
        ,	password 	: "phil"
        ,	create 		: true
        ,	read 		: true
        ,	update 		: true
        ,	delete 		: true
        ,	admin 		: false
      }),
      success: function(data){ console.log("success", data); },
      error: function(err){ console.log("error", err); },
      dataType: "json"
    });

#####Get all users :

    $.ajax({
      type: "GET",
      url: "users",
      success: function(users){ console.log(users) }
    });

#####Get a user by pseudo :

    $.ajax({
      type: "GET",
      url: "users/pseudo/phil",
      success: function(human){ console.log(human) }
    });

#####Update a user (you need id of user):

    $.ajax({
      type: "PUT",
      url: "users/52b6baaa3004530ace382ae1",
      data: JSON.stringify({
          pseudo 		: "phil"
        ,	password 	: "philip"
        ,	create 		: true
        ,	read 		: true
        ,	update 		: true
        ,	delete 		: true
        ,	admin 		: true
      }),
      success: function(data){ console.log("success", data); },
      error: function(err){ console.log("error", err); },
      dataType: "json"
    });

#####Delete a user (you need id of user):

    $.ajax({
      type: "DELETE",
      url: "users/52b6baaa3004530ace382ae1",
      success: function(message){ console.log(message) }
    });

----
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

