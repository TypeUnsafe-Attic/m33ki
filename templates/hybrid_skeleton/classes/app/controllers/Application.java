package app.controllers;

import app.models.*;
import app.tools.Json;

public class Application {

  public String about() {
    Message message = new Message("This is an hybrid M33kI application");
    return Json.stringify(message);
  }

}