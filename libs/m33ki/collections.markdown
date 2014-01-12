
# Documentation for `m33ki.collections`




## Functions

### `Collection()`

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




## Augmentations


## Structs

