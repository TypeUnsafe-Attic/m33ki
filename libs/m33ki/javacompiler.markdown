
# Documentation for `m33ki.javacompiler`




## Functions

### `loadClasses(javaClassDirectory, classes, compilation)`

#THIS IS EXPERIMENTAL

  # java classes factory
  let classFactory = loadClasses(
      "samples/hybrid/app"
    , list[
        "models.Human"
      , "controllers.Humans"
      ]
    , true # compilation if needed
  )

  let human = classFactory: load("models.Human"): getConstructor(String.class, String.class)
  let humanNoParameter = classFactory: load("models.Human")

  let humansController = classFactory: load("controllers.Humans")

  let john = humanNoParameter: newInstance()

  println(humansController: newInstance(): giveMeSomebody(): toString())




## Augmentations


## Structs

