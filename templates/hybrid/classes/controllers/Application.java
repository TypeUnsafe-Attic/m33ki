package controllers;

import models.*;

import java.lang.System;

public class Application {

  public models.Human giveMeSomebody() {
    System.out.println("get a human from controller");
    return new models.Human("JOHN", "DOE");
  }

  public String about() {
    return "<h1>This is an Hybrid application : Golo + Java</h1>";
  }

}