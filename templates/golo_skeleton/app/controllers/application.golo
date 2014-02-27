module controllers.application

import m33ki.spark
import m33ki.jackson
import models.about

function ApplicationController =  {

  return DynamicObject()
    : define("about", |this, request, response| {
        response: type("application/json")
        response: status(200)
        return Json(): toJsonString(
          map[["about", About(): message()]]
        )
    })
}