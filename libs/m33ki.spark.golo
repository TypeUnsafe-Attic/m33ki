module m33ki.spark

import m33ki.jackson
import m33ki.strings

import m33ki.hot

import spark.Spark
import java.io.File

import spark.Response

# CORS support
----
#### Sample

  GET("/hello/:who", |request, response| {
    response: type("application/json")
    response: allowCORS("*", "*", "*")
    return json: message("hello " + request: params(":who"))
  })
----
augment spark.Response {
  # === CORS support ===
  function allowCORS = |this, origin, methods, headers| {
    this: header("Access-Control-Allow-Origin", origin)
    this: header("Access-Control-Request-Method", methods)
    this: header("Access-Control-Allow-Headers", headers)
    return this
  }
  # === Server-Sent Events ===
  function initializeSSE = |this| {
    this: type("text/event-stream")
    this: header("Cache-Control", "no-cache")
    this: header("Connection", "keep-alive")
    this: status(200)
    this: raw(): setCharacterEncoding("UTF-8")
    return this
  }
  function writeSSE = |this, data| {
    let SSEData = "data:" + data + "\n\n"
    let out = this: raw(): getWriter()
    out: println(SSEData)
    out: flush()
    return this
  }
  function closeSSE = |this| {
    this: raw(): getWriter(): close()
    return this
  }
}

local function static = |path_static| -> externalStaticFileLocation(File("."): getCanonicalPath() + path_static)
local function port = |port_number| -> setPort(port_number)

function stop = |number, body| -> spark.AbstractRoute.halt(number, body)

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


# Routes
----
####Sample

    GET("/about"
      , |request, response| {
          println("plop")
        }
      , |request, response| {
          println("plop plop")
        }
      , |request, response| ->
          controllers.application.ApplicationController(): about(request, response)
    )

    GET("/authenticate"
      , |request, response| {
          let session = request: session(true)
          session: attribute("authenticated", true)
          return "Hello"
        }
    )

    GET("/logout"
      , |request, response| {
          let session = request: session(true)
          session: attribute("authenticated", false)
          return "Bye"
        }
    )

    # check authentication
    let check = |request, response| {
      println("checking")
      let session = request: session(true)

      if session: attribute("authenticated") is true {
        println("all is ok")
      } else {
        # response: redirect("/")
        # return false
        return [false, "<h1>Don't even think about this!</h1>"]
      }
    }

    GET("/try"
      , check # check authentication
      , |request, response| {
          return "<h1>Victory</h1>"
        }
    )
----
function route = |uri, closures| {
  let conf = map[
    ["extends", "spark.Route"],
    ["implements", map[
      ["handle", |this, request, response| {
          try {
            var res = null
            foreach(closure in closures) {
              res = closure(request, response)

              if res oftype gololang.Tuple.class {
                if res: get(0) is false {
                  res = res: get(1)
                  break
                }
              } else {
                if res is false {
                  break
                }
              }
            }
            return res
            #return method(request, response)
          } catch(e) {
            e:printStackTrace()
            request: session(): attribute("error", e)
            response: redirect("error")
            #throw e # ???
          }
      }]         
    ]]
  ]
  let Route = AdapterFabric(): maker(conf): newInstance(uri)
  return Route

}


function GET = |uri, handles...| { # uri = path
  return spark.Spark.get(route(uri, handles))
}

function POST = |uri, handles...| {
  return spark.Spark.post(route(uri, handles))
}

function PUT = |uri, handles...| {
  return spark.Spark.put(route(uri, handles))
}

function DELETE = |uri, handles...| {
  return spark.Spark.delete(route(uri, handles))
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
