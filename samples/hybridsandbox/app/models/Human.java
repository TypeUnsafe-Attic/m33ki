package models;

import java.lang.Override;
import java.lang.String;
import java.lang.System;

public class Human {
  public String firstName="John";
  public String lastName="Doe";

  public Human(String firstName, String lastName) {
    this.firstName = firstName;
    this.lastName = lastName;
    System.out.println(this.toString())
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