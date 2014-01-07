module simple.mongo

import m33ki.spark
import m33ki.collections
import m33ki.gandalf
import m33ki.authentication

import m33ki.models
import m33ki.mongodb

function Human = -> DynamicObject()
  :mixin(Model())
  :mixin(MongoModel(Mongo(): database("golodb"): collection("humans")))

function Humans = -> DynamicObject()
  :mixin(Collection())
  :mixin(MongoCollection(Human()))

function Animal = -> DynamicObject()
  :mixin(Model())
  :mixin(MongoModel(Mongo(): database("golodb"): collection("animals")))

function Animals = -> DynamicObject()
  :mixin(Collection())
  :mixin(MongoCollection(Animal()))


# needed for secured (authentication) mode
function MongoUser = -> DynamicObject()
  :mixin(User())
  :mixin(MongoModel(Mongo(): database("golodb"): collection("users")))

function MongoUsers = -> DynamicObject()
  :mixin(Collection())
  :mixin(MongoCollection(MongoUser()))


function main = |args| {
  let securityKey = "ultimatelanguageisgolo"

  #initialize(): static("/samples/simple.gandalf/public"): port(8888): error(true)
  initialize(): static("/public"): port(8888): error(true): listenForChange("")

  let users = MongoUsers()

  # get admins
  let admins = users: find("pseudo", "admin")

  if admins: size() > 0 {
    let admin = admins: toModelsList(): getFirst()
    println("--> Admin exists!!! : " + admin: toJsonString())
  } else {
    # create a default admin
    println("--> Admin creation ...")
    let newAdmin = MongoUser()
      : pwd(encrypt("admin", securityKey))
      : pseudo("admin")
      : admin(true)
      : canRead(true)
      : canCreate(true)
      : canUpdate(true)
      : canDelete(true)

    newAdmin: create()
    println("--> Admin created : " + newAdmin: toJsonString())
  }

  # Try this in console mode (with browser) to be authenticated
  # $.ajax({
  #   type: "POST",
  #   url: "login",
  #   data: JSON.stringify({pseudo:"admin", password:"admin"}),
  #   success: function(data){ console.log("success", data); },
  #   error: function(err){ console.log("error", err); },
  #   dataType: "json"
  # });


  CRUD(map[
      ["users", users]          # "users" key activates security
    , ["humans", Humans()]
    , ["animals", Animals()]
  ], securityKey)
}

