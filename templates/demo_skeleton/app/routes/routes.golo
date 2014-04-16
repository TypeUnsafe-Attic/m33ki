module routes

function loadRoutes = {

    m33ki.spark.GET("/about", |request, response| ->
      controllers.application.ApplicationController(): about(request, response))

}
