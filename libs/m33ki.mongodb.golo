module m33ki.mongodb

import com.mongodb.MongoClient
import com.mongodb.MongoException
import com.mongodb.WriteConcern
import com.mongodb.DB
import com.mongodb.DBCollection
import com.mongodb.BasicDBObject
import com.mongodb.DBObject
import com.mongodb.DBCursor
import com.mongodb.ServerAddress
import org.bson.types.ObjectId

import m33ki.collections

----
####Set MongoDb parameters

When you define models :

    function Human = -> DynamicObject()
      : mixin(Model())
      : mixin(
          MongoModel(
            Mongo()
              : database("golodb")
              : collection("humans")
          )
      )

You can do this :

    function Human = -> DynamicObject()
      : mixin(Model())
      : mixin(
          MongoModel(
            Mongo()
              : database("golodb")
              : collection("humans")
              : host("golo-inside")
              : port(42)
          )
      )

----
function Mongo =  {
  let db = DynamicObject()  # default values
    :host("localhost")
    :port(27017)
    :getDBInstance(|this, dataBaseName| {
      this: mongoClient(MongoClient(this: host(), this: port()))
      this: db(this: mongoClient(): getDB(dataBaseName))
      return this
    })
    :database(|this, dataBaseName| -> this: getDBInstance(dataBaseName))
    :collection(|this, collectionName| {
      return this: db(): getCollection(collectionName)
    })

  return db
}

#MongoModel(Mongo(): database("golodb"): collection("goloCollection"))
function MongoModel = |mongoCollection|{
  let mongoModel = DynamicObject():collection(mongoCollection)

  mongoModel: create(|this| { # insert in collection, callBack ?
    let dbObject = BasicDBObject("fields", this: fields() )
    this: collection(): insert(dbObject)
    this: fields(): put("id", dbObject: getObjectId("_id"): toString())
    return this
  })

  mongoModel: fetch(|this, id| { # get one model by id, callBack ?
    #println("ID----> " + id)
    #let doc = this: collection(): findOne(BasicDBObject("_id", ObjectId(id)))

    let doc = this: collection(): find(BasicDBObject("_id", ObjectId(id))): next()

    if doc isnt null {
      this: fields(doc: get("fields"))
      this: fields(): put("id", doc: getObjectId("_id"): toString())
    }
    return this
  })

  # TO BE TESTED / Some side effects
  mongoModel: update(|this| { # update one model , callBack ?
    let id = this: fields(): get("id"): toString()
    #let doc = this: collection(): findOne(BasicDBObject("_id", ObjectId(id)))
    
    let doc = this: collection(): find(BasicDBObject("_id", ObjectId(id))): next()

    try {
      let newDoc = BasicDBObject()
      newDoc: append("$set", BasicDBObject(): append("fields", this: fields()))
      this: collection(): update(doc, newDoc)
    } catch (e) {
      println(e:getMessage())
    } finally {
      return this
    }

  })

  mongoModel: delete(|this, id| { # delete one model by id, callBack ?
    #let doc = this: collection(): findOne(BasicDBObject("_id", ObjectId(id)))

    let doc = this: collection(): find(BasicDBObject("_id", ObjectId(id))): next()
    
    this: collection(): remove(doc)
    return this
  })

  return mongoModel
}

#TODO: some query helpers (find first etc. ... <> <= ...)

function MongoCollection = |mongoModel|{
  let mongoColl = DynamicObject(): model(mongoModel): kind("mongodb")

  # get all models
  mongoColl: fetch(|this| { # TODO: callback ?
    let cursor = this: model(): collection(): find()
    let memoryCollection = Collection()
    cursor: each(|doc| {
      let model = this: model(): copy()
      model: fields(doc: get("fields"))
      model: fields(): put("id", doc: getObjectId("_id"): toString())
      memoryCollection: addItem(model)
    })
    cursor: close()
    return memoryCollection
  })

  # sortOrder : 1 or -1
  mongoColl: lastN(|this, n, sortOrder| {
    let cursor = this: model(): collection(): find(): sort(BasicDBObject("_id", sortOrder)): limit(n)
    #db.foo.find().sort({_id:1}).limit(50);
    let memoryCollection = Collection()
    cursor: each(|doc| {
      let model = this: model(): copy()
      model: fields(doc: get("fields"))
      model: fields(): put("id", doc: getObjectId("_id"): toString())
      memoryCollection: addItem(model)
      #println(model: toJsonString())
    })
    cursor: close()
    return memoryCollection
  })


  #coll: find("firstName", "John") (! return memory collection)
  mongoColl: find(|this, fieldName, value| {
    let memoryCollection = Collection()

    let cursor = this: model(): collection()
      : find(BasicDBObject("fields."+fieldName, value))
      : each(|doc| {
          let model = this: model(): copy()
          model: fields(doc: get("fields"))
          model: fields(): put("id", doc: getObjectId("_id"): toString())
          memoryCollection: addItem(model)
        })
      : close()
    return memoryCollection
  })
  #coll: like("firstName", ".*o.*") (! return memory collection)
  mongoColl: like(|this, fieldName, value| {
    let memoryCollection = Collection()

    let cursor = this: model(): collection()
      : find(BasicDBObject("fields."+fieldName, java.util.regex.Pattern.compile(value)))
      : each(|doc| {
          let model = this: model(): copy()
          model: fields(doc: get("fields"))
          model: fields(): put("id", doc: getObjectId("_id"): toString())
          memoryCollection: addItem(model)
        })
      : close()
    return memoryCollection
  })


  return mongoColl
}
