module m33ki.redis.persistence

import redis

struct model = {
  kind,
  fields
}

struct persistenceHelper = {
  kind,
  redisDb
}

augment persistenceHelper {
  function save = |this, model| {
    require(
      model: kind() isnt null and
      model: kind(): equals(this: kind()) and
      model: fields() isnt null and
      model: fields(): get("id") isnt null,
      "not a model or bad kind of model!"
    )
    this: redisDb(): save(model: kind() + ":" + model: fields(): get("id"), model: fields())
  }
  function fetch = |this, key| -> this: redisDb(): fetch(this: kind() + ":" + key)
  function all = |this, qKey| -> this: redisDb(): all(this: kind() + ":" + qKey)
  function delete = |this, key| -> this: redisDb(): delete(this: kind() + ":" + key)

}


