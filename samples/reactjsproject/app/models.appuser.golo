module models.appuser

import m33ki.authentication   # Generic user
import m33ki.collections
import m33ki.models
import m33ki.mongodb

import application

# needed for secured (authentication) mode
# Model
function AppUser = -> DynamicObject()
  :mixin(User())
  :mixin(MongoModel(Mongo(): database(getDBName()): collection("appusers")))

# Collection
function AppUsers = -> DynamicObject()
  :mixin(Collection())
  :mixin(MongoCollection(AppUser()))