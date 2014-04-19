module simple

import m33ki.spark
import m33ki.jackson

function main = |args| {

  let humans = list[]

  # create some humans
  let bob = map[["id", "bob"], ["firstName", "Bob"], ["lastName", "Morane"]]
  let john = map[["id", "john"], ["firstName", "John"], ["lastName", "Doe"]]
  let jane = map[["id", "jane"], ["firstName", "Jane"], ["lastName", "Doe"]]

  humans: append(bob): append(john): append(jane)

  initialize(): static("/samples/simple/public"): port(8888)

  # Create a human
  POST("/humans", |request, response| {
    let human = Json(): toTreeMap(request: body())
    human: put("id", java.util.UUID.randomUUID(): toString())
    humans: append(human)

    response: json(Json(): toJsonString(human)): status(201) # 201: created
  })

  # Retrieve all humans
  GET("/humans", |request, response| {
    response: json(Json(): toJsonString(humans)): status(200)
  })

  # Retrieve a human by id
  GET("/humans/:id", |request, response| {
    response: json(
      Json(): toJsonString(
        humans: filter(|human| -> human: get("id"): equals(request: params(":id"))): get(0)
      )
    ): status(200)
  })

}
