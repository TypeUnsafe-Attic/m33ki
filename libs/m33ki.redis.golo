module m33ki.redis

import redis.clients.jedis.Jedis

# Redis Klass
# properties
struct redis = {
    host
  , port
  , _db # private member
}

# methods
augment redis {
  function connect = |this| {
    this: _db(Jedis(this: host(), this: port()))
    return this
  }
  function save = |this, key, fields| -> this: _db(): hmset(key, fields)
  function fetch = |this, key| -> this: _db(): hgetAll(key)
  function allKeys = |this, qKey| -> this: _db(): keys(qKey)
  function all = |this, qKey| -> this: allKeys(qKey): map(|key| -> this: fetch(key))
  function delete = |this, key| -> this: _db(): del(key)
}

# constructor
----
##Sample :
##Sample

    #let redis = Redis(): host("localhost"): port(6379): connect()
    let redis = Redis(): connect()

    redis: save("superhero:peter",
      map[["firstName", "Peter"],["lastName", "Parker"]])

    redis: save("superhero:clark",
      map[["firstName", "Clark"],["lastName", "Kent"]])

    println(redis: fetch("superhero:peter"))
    println(redis: fetch("superhero:clark"))

    println("===========================")

    redis: all("superhero:*"): each(|hero|{
      println(hero)
    })
----
function Redis = { # with default parameters
  return redis(): host("localhost"): port(6379)
}
# end of Redis Klass
