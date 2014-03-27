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
import m33ki.jackson


function Mongo =  { # configuration

  let db = DynamicObject()  # default values
    : host("localhost")     # easily change because it's a DynamicObject
    : port(27017)
    : define("database", |this, dataBaseName| { # getDBInstance
        this: mongoClient(MongoClient(this: host(), this: port()))
        this: db(this: mongoClient(): getDB(dataBaseName))
        return this
    })
    : define("collection", |this, collectionName| { # returns a com.mongodb.DBCollection
        return this: db(): getCollection(collectionName)
    })

  return db
}


function MongoModel = |db_collection| {
  # db_collection is a com.mongodb.DBCollection

  # private variable
  let collection = db_collection
  #var basicDBObject = BasicDBObject()

  let mongoModel = DynamicObject(): basicDBObject(BasicDBObject())

  mongoModel: define("getId", |this| {
    return this: basicDBObject(): getObjectId("_id"): toString()
  })

  mongoModel: define("setField", |this, fieldName, lastName| {
    this: basicDBObject(): put(fieldName, lastName)
    return this
  })

  mongoModel: define("getField", |this, fieldName| {
    return this: basicDBObject(): get(fieldName)
  })

  mongoModel: define("insert", |this| {
    collection: insert(this: basicDBObject())
    return this
  })

  mongoModel: define("update", |this| {
    let id = this: basicDBObject(): get("_id")
    this: basicDBObject(): removeField("_id")
    let searchQuery = BasicDBObject(): append("_id", ObjectId(id))
    collection: update(searchQuery, this: basicDBObject())
    this: basicDBObject(): put("_id", ObjectId(id))
    return this
  })

  mongoModel: define("fetch", |this, id| {
    let searchQuery = BasicDBObject(): append("_id", ObjectId(id))
    this: basicDBObject(): putAll(collection: findOne(searchQuery))
    return this
  })

  mongoModel: define("remove", |this, id| {
    let searchQuery = BasicDBObject(): append("_id", ObjectId(id))
    let doc = collection: find(searchQuery): next()
    this: basicDBObject(): putAll(doc)
    collection: remove(doc)
    return this
  })

  mongoModel: define("readable", |this| { # return map
    let map = this: basicDBObject(): toMap()
    map: put("_id", this: getId())
    return map
  })

  mongoModel: define("fromMap", |this, fieldsMap| {
    this: basicDBObject(BasicDBObject(fieldsMap))
    return this
  })

  mongoModel: define("toJsonString", |this| {
    return Json(): toJsonString(this: readable())
  })

  mongoModel: define("fromJsonString", |this, body| {
    let bo = BasicDBObject()
    bo: putAll( Json(): toTreeMap(body) )
    this: basicDBObject(bo)
    return this
  })

  return mongoModel # this is a DynamicObject
}

# http://api.mongodb.org/java/2.11.4/com/mongodb/DBCursor.html
# http://api.mongodb.org/java/2.11.4/com/mongodb/QueryBuilder.html
# http://stackoverflow.com/questions/14314692/simple-query-in-mongodb-in-java


function MongoCollection = |mongoModel, db_collection|{
  # db_collection is a com.mongodb.DBCollection

  # private variable
  let collection = db_collection

  # helpers :
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

  let mongoCollection = DynamicObject()
    : skip(null)
    : limit(null)
    : sort(null)

  mongoCollection: define("model", |this| -> mongoModel(db_collection)) # "model factory"


  mongoCollection: define("options", |this, cursor| {
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
  mongoCollection: define("fetch", |this| {
    let cursor = collection: find() # lazy fetch
    this: options(cursor)
    return cursorToList(cursor)
  })

  # find models (value objects)
  #coll: find("firstName", "John")
  mongoCollection: define("find", |this, fieldName, value| {
    let query = BasicDBObject(fieldName, value)
    let cursor = collection: find(query)
    this: options(cursor)
    return cursorToList(cursor)
  })

  #coll: like("firstName", ".*o.*")
  mongoCollection: define("like", |this, fieldName, value| {
    let query = BasicDBObject(fieldName, java.util.regex.Pattern.compile(value))
    let cursor = collection: find(query)
    this: options(cursor)
    return cursorToList(cursor)
  })

  mongoCollection: define("query", |this, query| {
    # query is a com.mongodb.QueryBuilder
    let cursor = collection: find(query)
    this: options(cursor)
    return cursorToList(cursor)
  })
  # let query = QueryBuilder.start("pseudo"): notEquals("@sam"): get()
  # buddies: query(query)

  return mongoCollection # this is a DynamicObject
}

# helper
# http://api.mongodb.org/java/2.12/com/mongodb/QueryBuilder.html
function Qb = |start|-> com.mongodb.QueryBuilder.start(start)

augment com.mongodb.QueryBuilder {
  function isEquals = |this, object| {
    return this: `is(object)
  }
}

# let query = Qb("pseudo"): notEquals("@sam"): get()
# buddies: query(query)


