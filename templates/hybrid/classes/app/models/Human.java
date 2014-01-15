package app.models;

import java.lang.Override;
import java.lang.String;
import java.lang.System;

public class Human {
  public String firstName=null;
  public String lastName=null;

  public Human(String firstName, String lastName) {
    this.firstName = firstName;
    this.lastName = lastName;
    System.out.println("Human Constructor : " + this.toString());
  }

  public Human() {
    System.out.println("Human Constructor");
  }

  @Override
  public String toString() {
    return "Human{" +
            "firstName=" + firstName +
            ", lastName=" + lastName +
            '}';
  }
}