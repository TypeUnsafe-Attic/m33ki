module models.message

import m33ki.collections
import m33ki.models
import m33ki.mongodb

import application

# Model
function Message = -> DynamicObject()
  :mixin(Model())
  :mixin(MongoModel(Mongo(): database(getDBName()): collection("messages")))

# Collection
function Messages = -> DynamicObject()
  :mixin(Collection())
  :mixin(MongoCollection(Message()))