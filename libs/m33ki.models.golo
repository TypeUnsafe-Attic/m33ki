module m33ki.models

import m33ki.jackson

#TODO: validation

function Model = -> DynamicObject()
    : fields(map[])
    : define("toJsonString", |this| {
        return Json(): stringify(Json(): toJson(this: fields()))
      })
    : define("fromJsonString", |this, body| {
        this: fields( Json(): toTreeMap(body) )
        return this
      })
    : define("generateId", |this|{
        this: fields(): put("id", java.util.UUID.randomUUID(): toString())
        return this
      })
    : setField(|this, fieldName, value| {
        this: fields(): put(fieldName, value)
        return this
      })
    : getField(|this, fieldName| {
        return this: fields(): get(fieldName)
      })
    : deleteField(|this, fieldName| {
        this: fields(): remove(fieldName)
        return this
      })