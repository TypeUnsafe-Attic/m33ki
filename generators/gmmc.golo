#Golo MongoDB Models & Collections
module gmmc

function template_model = ->
"""<%@params infos %>module models.<%= infos: model_name(): toLowerCase() %>

import m33ki.collections
import m33ki.models
import m33ki.mongodb

# Model
function <%= infos: model_name() %> = -> DynamicObject()
  : mixin(Model())
  : mixin(
      MongoModel(
        Mongo()
          : database("<%= infos: db_name() %>")
          : collection("<%= infos: db_collection_name() %>")
      )
  )

# Collection
function <%= infos: model_name() %>s = -> DynamicObject()
  : mixin(Collection())
  : mixin(
      MongoCollection(<%= infos: model_name() %>())
  )

"""

function template_routes = ->
"""<%@params infos %>module routes.<%= infos: model_name(): toLowerCase() %>

import m33ki.spark
import models.<%= infos: model_name(): toLowerCase() %>
import controllers.<%= infos: model_name(): toLowerCase() %>s

function define<%= infos: model_name() %>sRoutes = {

  # Collection Helper
  let <%= infos: model_name(): toLowerCase() %>s = <%= infos: model_name() %>s()

  # Create <%= infos: model_name() %>
  POST("/<%= infos: model_name(): toLowerCase() %>s", |request, response| {
    return <%= infos: model_name() %>sController(<%= infos: model_name(): toLowerCase() %>s): create(request, response)
  })

  # Retrieve all <%= infos: model_name() %>s
  GET("/<%= infos: model_name(): toLowerCase() %>s", |request, response| {
    return <%= infos: model_name() %>sController(<%= infos: model_name(): toLowerCase() %>s): getAll(request, response)
  })

  # Retrieve <%= infos: model_name() %> by id
  GET("/<%= infos: model_name(): toLowerCase() %>s/:id", |request, response| {
    return <%= infos: model_name() %>sController(<%= infos: model_name(): toLowerCase() %>s): getOne(request, response)
  })

  # Update <%= infos: model_name() %>
  PUT("/<%= infos: model_name(): toLowerCase() %>s/:id", |request, response| {
    return <%= infos: model_name() %>sController(<%= infos: model_name(): toLowerCase() %>s): update(request, response)
  })

  # delete <%= infos: model_name() %>
  DELETE("/<%= infos: model_name(): toLowerCase() %>s/:id", |request, response| {
    return <%= infos: model_name() %>sController(<%= infos: model_name(): toLowerCase() %>s): delete(request, response)
  })

}
"""

function template_controller = ->
"""<%@params infos %>module controllers.<%= infos: model_name(): toLowerCase() %>s

import m33ki.spark
import m33ki.jackson
import models.<%= infos: model_name(): toLowerCase() %>

function <%= infos: model_name() %>sController = |<%= infos: model_name(): toLowerCase() %>s| {

  return DynamicObject()
    : define("getAll", |this, request, response| {
      # GET request : get all models
        response: type("application/json")
        response: status(200)
        return <%= infos: model_name(): toLowerCase() %>s: fetch(): toJsonString()
    })
    : define("getOne", |this, request, response| {
      # GET request : get one model by id
        response: type("application/json")
        let id = request: params(":id")
        let <%= infos: model_name(): toLowerCase() %> = <%= infos: model_name(): toLowerCase() %>s: model(): fetch(id)

        if <%= infos: model_name(): toLowerCase() %> isnt null{
          response: status(200)
          return <%= infos: model_name(): toLowerCase() %>: toJsonString()
        } else {
          response: status(404) # 404 Not found
          return Json(): toJsonString(map[["message", "<%= infos: model_name() %> not found"]])
        }
    })
    : define("create", |this, request, response| {
      # POST request : create a model
        response: type("application/json")
        let <%= infos: model_name(): toLowerCase() %> = <%= infos: model_name(): toLowerCase() %>s: model(): fromJsonString(request: body())
        <%= infos: model_name(): toLowerCase() %>: create() # insert in collection
        response: status(201) # 201: created
        return <%= infos: model_name(): toLowerCase() %>: toJsonString()
    })
    : define("update", |this, request, response| {
      # PUT request : update a model
        response: type("application/json")
        let <%= infos: model_name(): toLowerCase() %> = <%= infos: model_name(): toLowerCase() %>s: model(): fromJsonString(request: body())
        <%= infos: model_name(): toLowerCase() %>: update() # update in collection
        response: status(200) # 200: Ok + return data
        return <%= infos: model_name(): toLowerCase() %>: toJsonString()
    })
    : define("delete", |this, request, response| {
      # DELETE request : delete a model
        response: type("application/json")
        let id = request: params(":id")
        let <%= infos: model_name(): toLowerCase() %> = <%= infos: model_name(): toLowerCase() %>s: model(): delete(id)
        response: status(200) # 200: Ok + return data
        return <%= infos: model_name(): toLowerCase() %>: toJsonString()
    })
    : define("getLast", |this| {
        return <%= infos: model_name(): toLowerCase() %>s: lastN(1, -1)
    })
    : define("getLastN", |this, N| {
        return <%= infos: model_name(): toLowerCase() %>s: lastN(N, -1)
    })
    : define("find", |this, fieldName, equalsValue| {
        return <%= infos: model_name(): toLowerCase() %>s: find(fieldName, equalsValue)
    })
    : define("like", |this, fieldName, likesValue| {
        return <%= infos: model_name(): toLowerCase() %>s: like(fieldName, likesValue)
    })

    #W.I.P.
}

"""


function template_generated_routes = ->
"""<%@params routes %>module generated.routes

<% foreach route in routes { %>
  import <%= route: import_route() %><% } %>

function defineAllGeneratedRoutes = {
  <% foreach route in routes { %>
    <%= route: function_name() %><% } %>
}

"""

function generator = |applicationDirectory| {

  println("=== Golo MongoDB Models & Collections ===")
  println("")
  let db_name = readln("MongoDB Database name ?")
  let db_collection_name = readln("MongoDB Collection ?")

  let model_name = readln("Model name ?")

  let infos = DynamicObject()
      : db_name(db_name)
      : db_collection_name(db_collection_name)
      : model_name(model_name)

  # generate model source code
  let output_model = gololang.TemplateEngine(): compile(template_model())
  let model_source_code = output_model(infos)
  textToFile(model_source_code, applicationDirectory+"/app/models."+model_name: toLowerCase()+".golo")
  println(applicationDirectory+"/app/models."+model_name: toLowerCase()+".golo generated")

  # generate routes source code
  let output_routes = gololang.TemplateEngine(): compile(template_routes())
  let routes_source_code = output_routes(infos)
  textToFile(routes_source_code, applicationDirectory+"/app/routes."+model_name: toLowerCase()+".golo")
  println(applicationDirectory+"/app/routes."+model_name: toLowerCase()+".golo generated")

  # generate controller source code
  let output_controller = gololang.TemplateEngine(): compile(template_controller())
  let controller_source_code = output_controller(infos)
  textToFile(controller_source_code, applicationDirectory+"/app/controllers."+model_name: toLowerCase()+"s.golo")
  println(applicationDirectory+"/app/controllers."+model_name: toLowerCase()+"s.golo generated")

  # re-generate routes loader
  let dir = java.io.File(applicationDirectory + "/app")

  let routes = list[]

  dir: listFiles(): asList(): each(|file| {
    #println(file: getName())
    if file: getName(): startsWith("routes.") {

      let import_route = file: getName(): split(".golo"): get(0)
      let model_route = file: getName(): split("routes."): get(1): split(".golo"): get(0)

      routes: add(
        DynamicObject()
          : import_route(import_route)
          : function_name("define"+java.lang.Character.toUpperCase(model_route: charAt(0)) + model_route: substring(1)+"sRoutes()")
      )
    }
  })

  # generate routes file loader

  let output_route_loader = gololang.TemplateEngine(): compile(template_generated_routes())
  let route_loader_source_code = output_route_loader(routes)
  textToFile(route_loader_source_code, applicationDirectory+"/app/generated.routes.golo")
  println(applicationDirectory+"/app/generated.routes.golo generated")

}