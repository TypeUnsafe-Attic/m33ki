package controllers;

import models.*;

import java.lang.System;

public class Humans {
  public models.Human giveMeSomebody() {
    System.out.println("get a human from controller");
    return new models.Human("JOHN", "DOE");
  }

}

