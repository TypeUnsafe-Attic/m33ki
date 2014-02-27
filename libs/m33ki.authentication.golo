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
  println("decryptedValue : " + decryptedValue)
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

#if Session(request): admin() is true {}

# to extend user Model
function UserWithRights = |securityKey| {

  return DynamicObject()
    : securityKey(securityKey)
    : define("setStdRights", |this| {
        this: setField("admin", false)
        : setField("read", true)
        : setField("create", false)
        : setField("update", false)
        : setField("delete", false)
      })
    : define("setAdminRights", |this| {
        this: setField("admin", true)
        : setField("read", true)
        : setField("create", true)
        : setField("update", true)
        : setField("delete", true)
      })
    : define("encryptPwd", |this| {
        # encrypt password
        let pwd = this: getField("password")
        this: setField("password", encrypt(pwd, this: securityKey()))
        return this
      })
}

# to extend Users Collection

function findOrCreateAdmin = |users, pseudo, password| {

   let admins = users: findReadable("pseudo", pseudo)

   if admins: size() > 0 {
     let admin = admins: getFirst()
     println("--> Admin exists!!! : " + admin)
   } else {
     # create a default admin
     println("--> Admin creation ...")

     let newAdmin = users: model()
     newAdmin
      : setField("pseudo", pseudo)
      : setField("password", password)
      : encryptPwd()
      : setAdminRights()

     newAdmin: insert() # insert in collection

     println("--> Admin created : " + newAdmin: toJsonString())
   }
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
function AUTHENTICATION = |users, onLogin, onLogout, ifAuthenticated| {

  println("--- Define Authentication routes ---")

  let securityKey = users: model(): securityKey()

  # Login
  # OK for memory Users and mongoDb Users
  POST("/login", |request, response| {
    println("--> authentication attempt")
    response:type("application/json")
    let tmpUser = Model(): fromJsonString(request: body())

    println("--> user : " + tmpUser)
    println("--> user.pseudo : " + tmpUser: getField("pseudo"))
    #println("--> users :" + users: models())

    #let searchUser = users: find("pseudo", tmpUser: getField("pseudo")): toModelsList(): getFirst()

    let searchUsers = users: findReadable("pseudo", tmpUser: getField("pseudo")) #get map

    println("searchUsers : " + searchUsers)

    let session = request: session(true)

    # searchUsers is a collection
    if searchUsers: size() > 0 {
      let searchUser = searchUsers: getFirst()
      println("--> searchUser pseudo : " + searchUser: get("pseudo") )
      println("--> searchUser id : " + searchUser: get("_id") )

      if decrypt(searchUser: get("password"), securityKey): equals(tmpUser: getField("password")) {
        response: status(200) # OK

        session: attribute("id",  searchUser: get("_id"))
        session: attribute("pseudo",  searchUser: get("pseudo"))
        session: attribute("read",    searchUser: get("read"))
        session: attribute("create",  searchUser: get("create"))
        session: attribute("update",  searchUser: get("update"))
        session: attribute("delete",  searchUser: get("delete"))
        session: attribute("admin",   searchUser: get("admin"))

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

