module m33ki.mongodb2

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
import m33ki.jackson

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

function MongoModel = |mongoCollection|{

  let mongoModel = DynamicObject()
  let collection = mongoCollection
  let basicDBObject = BasicDBObject()

  mongoModel: collection(collection)
  mongoModel: basicDBObject(basicDBObject)

  mongoModel: getId(|this| {
    return this: basicDBObject(): getObjectId("_id"): toString()
  })

  #mongoModel: fields(basicDBObject)

  mongoModel: setField(|this, fieldName, lastName| {
    this: basicDBObject(): put(fieldName, lastName)
    return this
  })

  mongoModel: getField(|this, fieldName| {
    return this: basicDBObject(): get(fieldName)
  })

  mongoModel: insert(|this| {
    collection: insert(this: basicDBObject())
    return this
  })

  mongoModel: update(|this| {
    let id = this: basicDBObject(): get("_id")
    this: basicDBObject(): removeField("_id")
    let searchQuery = BasicDBObject(): append("_id", ObjectId(id))
    collection: update(searchQuery, this: basicDBObject())
    this: basicDBObject(): put("_id", ObjectId(id))
    return this
  })

  mongoModel: fetch(|this, id| {
    let searchQuery = BasicDBObject(): append("_id", ObjectId(id))
    this: basicDBObject(): putAll(collection: findOne(searchQuery))
    return this
  })

  mongoModel: remove(|this, id| {

    let searchQuery = BasicDBObject(): append("_id", ObjectId(id))
    #let doc = collection: findOne(searchQuery)
    let doc = collection: find(searchQuery): next()
    this: basicDBObject(): putAll(doc)
    #collection: remove(this: basicDBObject())
    collection: remove(doc)
    return this
  })

  mongoModel: readable(|this| {
    let map = this: basicDBObject(): toMap()
    map: put("_id", this: getId())
    return map
  })

  mongoModel: toJsonString(|this| {
    return Json(): toJsonString(this: readable())
  })

  mongoModel: fromJsonString(|this, body| {
    let bo = BasicDBObject()
    bo: putAll( Json(): toTreeMap(body) )
    this: basicDBObject(bo)
    return this
  })

  return mongoModel
}

function MongoCollection = |mongoModel|{
  let model = mongoModel
  let mongoColl = DynamicObject()

  mongoColl: model(mongoModel)

  # get all models
  mongoColl: fetchAllReadable(|this| {
    let cursor = this: model(): collection(): find()
    let models = list[]
    cursor: each(|doc| {
      let map = doc: toMap()
      let id = doc: getObjectId("_id"): toString()
      map: put("_id", id)
      models: add(map)
    })
    cursor: close()
    return models
  })

  # find models
  #coll: find("firstName", "John") (! return memory collection)
  mongoColl: findReadable(|this, fieldName, value| {

    let cursor = this: model(): collection()
      : find(BasicDBObject(fieldName, value))
    let models = list[]

    cursor: each(|doc| {
      let map = doc: toMap()
      let id = doc: getObjectId("_id"): toString()
      map: put("_id", id)
      models: add(map)
    })
    cursor: close()
    return models
  })


  return mongoColl
}
