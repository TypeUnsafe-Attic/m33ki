package app.controllers;

import app.models.*;

import java.lang.System;

public class Application {

  public Human giveMeSomebody() {
    System.out.println("get a human from controller");
    return new Human("JOHN", "DOE");
  }

  public String about() {
    return "<h1>This is an Hybrid application : Golo + Java</h1>";
  }

}