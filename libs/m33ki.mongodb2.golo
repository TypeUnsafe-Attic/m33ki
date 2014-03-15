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
    :database(|this, dataBaseName| { # getDBInstance
      this: mongoClient(MongoClient(this: host(), this: port()))
      this: db(this: mongoClient(): getDB(dataBaseName))
      return this
    })
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

# http://api.mongodb.org/java/2.11.4/com/mongodb/DBCursor.html
# http://api.mongodb.org/java/2.11.4/com/mongodb/QueryBuilder.html
# http://stackoverflow.com/questions/14314692/simple-query-in-mongodb-in-java


function MongoCollection = |mongoModel, mongoCollection|{
  let mongoColl = DynamicObject()

  mongoColl: define("model", |this| {
    return mongoModel(mongoCollection)
  })

  mongoColl: collection(mongoCollection)

  mongoColl: skip(null)
  mongoColl: limit(null)
  mongoColl: sort(null)

  let cursorToList = |cursor| { # return list of HashMaps
    let models = list[]
    cursor: each(|doc| {
      let map = doc: toMap()
      let id = doc: getObjectId("_id"): toString()
      map: put("_id", id)
      models: add(map)
    })
    return models
  }


  mongoColl: options(|this, cursor| {
    if this: sort() isnt null {
      cursor: sort(BasicDBObject(this: sort(): get(0), this: sort(): get(1)))
      this: sort(null)
    }
    if this: skip() isnt null {
      cursor: skip(this: skip()): limit(this: limit())
      this: skip(null): limit(null)
    }
    return cursor
  })

  # get all models (value objects)
  mongoColl: fetch(|this| {
    let cursor = this: collection(): find() # lazy fetch
    this: options(cursor)
    return cursorToList(cursor)
  })

  # find models (value objects)
  #coll: find("firstName", "John")
  mongoColl: find(|this, fieldName, value| {
    let query = BasicDBObject(fieldName, value)
    let cursor = this: collection(): find(query)
    this: options(cursor)
    return cursorToList(cursor)
  })

  #coll: like("firstName", ".*o.*")
  mongoColl: like(|this, fieldName, value| {
    let query = BasicDBObject(fieldName, java.util.regex.Pattern.compile(value))
    let cursor = this: collection(): find(query)
    this: options(cursor)
    return cursorToList(cursor)
  })

  mongoColl: query(|this, query| {
    # query is a com.mongodb.QueryBuilder
    let cursor = this: collection(): find(query)
    this: options(cursor)
    return cursorToList(cursor)
  })
  # let query = QueryBuilder.start("pseudo"): notEquals("@sam"): get()
  # buddies: query(query)

  return mongoColl
}

function Qb = |start|-> com.mongodb.QueryBuilder.start(start)


