module m33ki.collections

import m33ki.jackson

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

#TODO: addItems