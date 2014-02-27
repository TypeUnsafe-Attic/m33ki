package app.controllers;

import app.models.*;
import app.tools.Json;

import static spark.Spark.*;
import spark.*;

public class Application {

  public String about(Request request, Response response) {
    response.type("application/json");
    response.status(200);
    Message message = new Message("This is an hybrid M33kI application");
    return Json.stringify(message);
  }

}