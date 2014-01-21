package app.controllers;

import app.models.*;
import app.tools.Json;

import static spark.Spark.*;
import spark.*;

import java.lang.System;

public class Application {

  public String getJane(Request request, Response response) {
    response.type("application/json");
    response.status(200);
    Human jane = new Human("Jane", "Doe");
    return Json.stringify(jane);
  }

  public Human giveMeSomebody() {
    System.out.println("get a human from controller");
    return new Human("JOHN", "DOE");
  }

  public String about() {
    return "<h1>This is an Hybrid application : Golo + Java</h1>";
  }

}