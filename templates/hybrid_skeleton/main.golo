module hybridapp

import m33ki.spark
import m33ki.jackson

import java.lang.String

import app.models.Human
import app.controllers.Application

import config

function main = |args| {
  initialize(): static("/public"): port(8888): error(true)
  listen(true) # listen to change, then compile java file

  GET("/about", |request, response| {
    response: json(Application(): about())
  })

}