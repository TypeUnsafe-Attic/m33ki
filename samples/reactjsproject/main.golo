module main

import m33ki.spark
import m33ki.jackson

# see /app/application.golo
import application                # configuration : getSecurityKey() getPort()
import m33ki.authentication
import models.appuser             # Model : AppUser(), Collection : AppUsers()
import controllers.appusersctrl   # AppUsersCtrl()

import models.message             # Model : Message(), Collection : Messages()
import controllers.messagesctrl   # MessagesCtrl()


#TODO: 404 page (!!! it's a SPA)

function main = |args| {

  initialize(): static(getPublic()): port(getPort()): error(true): listenForChange("app") # listen to root of the webapp  for "hot reloading"

  # === create collection linked to mongoDb ===
  let appUsersColl = AppUsers()
  let messagesColl = Messages()

  # create a default administrator if 0 administrator
  AppUsersCtrl(appUsersColl): findOrCreateAdmin()
  AppUsersCtrl(appUsersColl): findOrCreateUsers()

  AUTHENTICATION(
      AppUsers()
    , getSecurityKey()
    , |user, authenticated| { # on LogIn
        println(user: getField("pseudo") + " is authenticated : " + authenticated)
      }
    , |id, pseudo| { # on LogOut
        println(pseudo + "[" + id +  "] is gone ...")
      }
    , |id, pseudo| { # Authentication checking
        if id isnt null {
          println(pseudo +  " is online and authenticated ...")
        } else {
          println("Current user isn't authenticated ...")
        }
      }
  )

  ADMIN(AppUsers(), getSecurityKey())


  # my first little json service
  GET("/about", |request, response| {
    response: type("application/json")
    response: status(200)
    return Json(): toJsonString(map[["message", "ReactJS project"]])
  })

  POST("/signup", |request, response| { # will be a post
    return AppUsersCtrl(appUsersColl): signUp(request, response)
  })

  GET("/confirm/:who", |request, response| {
    return AppUsersCtrl(appUsersColl): createNewUser(request, response)
  })

  POST("/messages", |request, response| {
    return MessagesCtrl(messagesColl): createMessage(request, response)
  })

  # get all users list (for all)
  GET("/appusers", |request, response| {
    return AppUsersCtrl(appUsersColl): getAllUsers(request, response)
  })

  GET("/10last_messages", |request, response| {
    return MessagesCtrl(messagesColl): getLastTenMessages(request, response)
  })

  GET("/last_message", |request, response| {
    return MessagesCtrl(messagesColl): getLastMessage(request, response)
  })

}
