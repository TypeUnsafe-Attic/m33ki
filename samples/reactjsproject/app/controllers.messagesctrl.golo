module controllers.messagesctrl

import m33ki.authentication
import m33ki.jackson
import application
import models.message

function MessagesCtrl = ->
  DynamicObject()
    : define("createMessage", |this, request, response|{
        response: type("application/json")

        let messagesCollection = Messages()
        let messageModel = messagesCollection: model(): fromJsonString(request: body())

        let sessionInfo = Session(request)

        if sessionInfo: id() isnt null { # try filter
          messageModel: setField("fromId", sessionInfo: id())
          messageModel: setField("fromPseudo", sessionInfo: pseudo())

          try {
            messageModel: create() # insert in collection
            response: status(201) # 201: created
            return messageModel: toJsonString()

          } catch (e) {
            response: status(500) #
            return Json(): message("Huston, we've got a problem")
          }
        } else {
          response: status(403) # forbidden
          return Json(): message("not authenticated")
        }

      })
