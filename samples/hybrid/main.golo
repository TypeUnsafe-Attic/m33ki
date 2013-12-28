module hybridapp

import m33ki.spark
import m33ki.jackson
import m33ki.javacompiler
import java.lang.String

----
    let conf = map[
      ["extends", "models.Human"],
      ["overrides", map[
        ["toString", |super, this| {
          return super(this)
        }]
      ]]
    ]
    let h = AdapterFabric(): maker(conf): newInstance()
----
function main = |args| {

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

  # static assets
  static("/samples/hybrid/public")
  port(8888)

  GET("/human", |request, response| {
    response:type("application/json")

    let bob = human: newInstance("Bob", "Morane")
    println(bob: firstName() + " " + bob: lastName())
    println(bob: toString())

    response: status(200) # 200: OK
    return Json(): toJsonString(bob)

  })


}