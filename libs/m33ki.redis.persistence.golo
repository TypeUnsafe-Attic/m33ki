module m33ki.redis.persistence

import m33ki.redis

function Model = |kind| {
  return DynamicObject()
    : kind(kind)
    : fields(map[])
    : define("getField", |this, fieldName| -> this: fields(): get(fieldName))
    : define("setField", |this, fieldName, value| {
        this: fields(): put(fieldName, value)
        return this
    })
}

function Collection = |redisDb, model_definition| {

  let model = model_definition

  model
    : define("save", |this| {
        let key = this: kind() + ":" + this: fields(): get("id")
        redisDb: save(key, this: fields())
        return this
    })
    : define("fetch", |this| {
      let fields = redisDb: fetch(this: kind() + ":" + this: fields(): get("id"))
      this: fields(fields)
      return this
    })
    : define("delete", |this| {
      redisDb: delete(this: kind() + ":" + this: fields(): get("id"))
      this: fields(null)
      return this
    })

  return DynamicObject()
    : define("model", |this| { # get instance of Model
        return model: copy()
    })
    : define("all", |this, qKey| -> # java.util.HashSet
        redisDb: allKeys(model: kind() + ":" + qKey): map(|key| -> this: model(): fields(redisDb: fetch(key)))
    )
}





