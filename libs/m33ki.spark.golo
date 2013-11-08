module m33ki.spark

import spark.Spark
import java.io.File

function static = |path| -> externalStaticFileLocation(File("."): getCanonicalPath() + path) 
function port = |port_number| -> setPort(port_number)

function route = |uri, method| {
  let conf = map[
    ["extends", "spark.Route"],
    ["implements", map[
      ["handle", |this, request, response| {
        return method(request, response)
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