module m33ki.collections

import m33ki.jackson

# Collection
#TODO: addItems : add several models
----
####Description

`Collection()` function return a DynamicObject with properties and methods to deal with `map[]` of `m33ki.models.Model()`.
*See [models](models.html)*.

####Properties

- `model()` : kind of model used by the current collection
- `models()` : map of models, key of map record is the `id` of model

####Methods

- `size()` returns size of collection
- `addItem(model)` add a model to the collection
- `getItem(id)` get model by `id`
- `removeItem(id)` remove model of the collection by `id`
- `forEach(somethingToDo)` execute somethingToDo closure for each model of the collection. The passed parameter to the closure is the iterated model of the collection
- `toList()` returns a `list[]` of model `fields()` (list of maps)
- `toModelsList()` returns a `list[]` of models
- `toJsonString()` returns a json string array representation of the collection
- `find(fieldName, value)` returns a models collection where field `fieldName` value equals `value`
- `like(fieldName, value)` returns a models collection where field `fieldName` value is "like" `value` (ie: `value = ".*am.*"` : contains "am")

----
function Collection = -> DynamicObject(): kind("memory")
  : model("") # ?
  : models(map[])
  : size(|this|-> this: models(): size())
  : addItem(|this, model| {
      # you need an id, it's a map
      if model: getField("id") is null {
        model: generateId()
      }
      this: models(): put(model: getField("id"), model)
      return this
    })
  : getItem(|this, id| -> this: models(): get(id))
  : removeItem(|this, id| -> this: models(): remove(id))
  : define("forEach", |this, todo| {
      this: models(): each(|key, model|{
        todo(model)
      })
      return this
    })
  : toList(|this| {
      let coll = DynamicObject(): items(list[])
      this: models(): each(|key, model|{
        coll: items(): add(model: fields())
      })
      return coll: items()
    })
  : toModelsList(|this|{
      let coll = DynamicObject(): items(list[])
      this: models(): each(|key, model|{
        coll: items(): add(model)
      })
      return coll: items()
    })
  : toJsonString(|this| {
      return Json(): toJsonString(this: toList())
    })
  : find(|this, fieldName, value| {
      let coll = Collection()

      this: models(): filter(|key, model|{
        return model: getField(fieldName): equals(value)
      }): each(|key, model|{
        coll: addItem(model)
      })

      return coll
    })
  : like(|this, fieldName, value| {
      let coll = Collection()

      this: models(): filter(|key, model|{
        return model: getField(fieldName): matches(value)
      }): each(|key, model|{
        coll: addItem(model)
      })

      return coll

    })
