module m33ki.collections

import m33ki.jackson

function Collection = -> DynamicObject()
  :model("")
  :models(map[])
  :addItem(|this, model| {
    this: models(): put(model: getField("id"), model)
    return this
  })
  :getItem(|this, id| -> this: models(): get(id))
  :removeItem(|this, id| -> this: models(): remove(id))
  :toList(|this| {
    let coll = DynamicObject(): items(list[])
    this: models(): each(|key, model|{
      coll: items(): add(model: fields())
    })
    return coll: items()
  })
  :toJsonString(|this| {
    return Json(): toJsonString(this: toList())
  })

#TODO: addItems