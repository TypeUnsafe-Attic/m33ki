module m33ki.redis.persistence

import m33ki.redis

----
# kind of model
function Human = |redisDb| {

  return DynamicObject(): mixin(Model("Human", redisDb))
    : define("setName", |this, name| {
        return this: setField("name", name)
    })
    : define("getName", |this| -> this: getField("name"))
    : define("setId", |this, id| {
        return this: setField("id", id)
    })
    : define("getId", |this| -> this: getField("id"))
}

function main = |args| {

  let redisDb = Redis(): connect()

  let humans = Collection(Human(redisDb))

  let bob = Human(redisDb): setId("bob"): setName("Bob Morane")
  let john = Human(redisDb): setId("john"): setName("John Doe")
  let jane = Human(redisDb): setId("jane"): setName("Jane Doe")

  bob: save()
  john: save()
  jane: save()

  println("=== All ===")

  humans: query("*"): each(|human| -> println("-" + human: fields()))

  println("=== Some ===")

  humans: query("*o*"): each(|human| -> println(human: fields()))

}
----
function Model = |kind, redisDb| {

  return DynamicObject()
    : redisDb(redisDb)
    : kind(kind)
    : fields(map[])
    : define("getField", |this, fieldName| -> this: fields(): get(fieldName))
    : define("setField", |this, fieldName, value| {
        this: fields(): put(fieldName, value)
        return this
    })
    : define("save", |this| {
        let key = this: kind() + ":" + this: fields(): get("id")
        this: redisDb(): save(key, this: fields())
        return this
    })
    : define("fetch", |this| {
      let fields = this: redisDb(): fetch(this: kind() + ":" + this: fields(): get("id"))
      this: fields(fields)
      return this
    })
    : define("delete", |this| {
      this: redisDb(): delete(this: kind() + ":" + this: fields(): get("id"))
      this: fields(null)
      return this
    })
}

function Collection = |model_definition| {

  return DynamicObject()
    : define("query", |this, qKey| -> # java.util.HashSet
        model_definition: redisDb()
          : allKeys(model_definition: kind() + ":" + qKey)
            : map(|key| -> model_definition: copy(): fields(model_definition: redisDb(): fetch(key)))
    )
}




