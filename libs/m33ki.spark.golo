module m33ki.spark

import m33ki.jackson
import m33ki.strings

import m33ki.hot

import spark.Spark
import java.io.File

local function static = |path_static| -> externalStaticFileLocation(File("."): getCanonicalPath() + path_static)
local function port = |port_number| -> setPort(port_number)


function initialize = {

  #request.session().id()
  #here logo

  return DynamicObject()
    : define("static", |this, path_static| {
        static(path_static)
        return this
      })
    : define("port", |this, port_number| {
        port(port_number)

        # ie: useful for linking session to socket connection
        #GET("/session_id", |request, response| {
        #  response: type("text/plain")
        #  response: status(200)
        #  return request: session(): id()
        #})

        return this
      })
    : define("error", |this, generic_error_management| {
        if generic_error_management is true { define_error_redirection() }
        return this
      })
    : define("listenForChange", |this, path| {
        listenForChange(path) # from m33ki.hot | hot reloading of golo scripts
        return this
      })
    : define("listenForChangeThenCompile", |this, path, javaSourcePath, packageBaseName, jarPath, jarName| {
        listenForChangeThenCompile(path, javaSourcePath, packageBaseName, jarPath, jarName) # from m33ki.hot | hot reloading of golo scripts and java file + compilation
        return this
      })

}

function route = |uri, method| {
  let conf = map[
    ["extends", "spark.Route"],
    ["implements", map[
      ["handle", |this, request, response| {
          try {
            return method(request, response)
          } catch(e) {
            e:printStackTrace()

            #request: session(): attribute("error_msg", e: getMessage())
            #request: session(): attribute("error_stk", e: getStackTrace(): toString())

            request: session(): attribute("error", e)

            #request: session(): attribute("error_stk", Json(): toJsonString(e: getStackTrace()))
            response: redirect("error")
            #throw e # ???
          }
      }]         
    ]]
  ]
  let Route = AdapterFabric(): maker(conf): newInstance(uri)
  return Route

}


function GET = |uri, method| {
  return spark.Spark.get(route(uri, method))
}

function POST = |uri, method| {
  return spark.Spark.post(route(uri, method))
}

function PUT = |uri, method| {
  return spark.Spark.put(route(uri, method))
}

function DELETE = |uri, method| {
  return spark.Spark.delete(route(uri, method))
}


function define_error_redirection = {
  GET("/error", |request, response| {

    response:type("text/html")

    let data = DynamicObject()
      : description(request: session(): attribute("error"): toString())
      : message(request: session(): attribute("error"): getMessage())
      : stack(request: session(): attribute("error"): getStackTrace())
      : define("ext", |this, name| {
          if name isnt null {
            let dot = name: lastIndexOf(".")
            return name: substring(dot + 1)
          } else {
            return ""
          }

        })
      : define("isGolo", |this, name| {
          if this: ext(name): equals("golo") { return true } else { return false }
      })

		let html_response = """
			<style type="text/css">
				body {
				    font-family: Helvetica, Arial;
				    font-size: 18px;
				    color: #3A4244;
				    margin : 15px;
				}
				.golo { color: #FF0000; }
			</style>
			<h1><%= data: message() %></h1>
			<h2><%= data: description() %></h2>

			<ul>
			  <% foreach stkTrElement in data: stack() { %>
			    <li>
			      <% if data: isGolo(stkTrElement: getFileName()) is true { %> <b class="golo"> <% } %>
			      [<%= stkTrElement: getFileName() %> : <%= stkTrElement: getLineNumber() %>] (<%= stkTrElement: getClassName() %>) -> <%= stkTrElement: getMethodName() %>
			      <% if data: isGolo(stkTrElement: getFileName()) is true { %> </b> <% } %>
			    </li>
				<% } %>
			</ul>
		"""
		:T("data", data)

    return html_response

  })
}