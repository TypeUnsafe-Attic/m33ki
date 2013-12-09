module m33ki.collections

import m33ki.jackson

function Collection = -> DynamicObject(): kind("memory")
  : model("") # ?
  : models(map[])
  : addItem(|this, model| {
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
  : toJsonString(|this| {
      return Json(): toJsonString(this: toList())
    })
  :  find(|this, fieldName, value| {
      let coll = Collection()

      this: models(): filter(|key, model|{
        return model: getField(fieldName): equals(value)
      }): each(|key, model|{
        coll: addItem(model)
      })

      return coll

    })

#TODO: addItems