module controllers.messagesctrl

import m33ki.authentication
import m33ki.jackson

import application
import models.message

function MessagesCtrl = |messagesCollection| {

  return DynamicObject()
    : define("createMessage", |this, request, response|{
        response: type("application/json")
        let messageModel = messagesCollection: model(): fromJsonString(request: body())
        let sessionInfo = Session(request)

        if sessionInfo: id() isnt null { # try filter
          messageModel: setField("fromId", sessionInfo: id())
          messageModel: setField("fromPseudo", sessionInfo: pseudo())
          messageModel: setField("publication", java.util.Date())

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
    : define("getLastTenMessages", |this, request, response| {
        response: type("application/json")
        response: status(200)
        return messagesCollection: lastN(10, -1): toJsonString()

    })
    : define("getLastMessage", |this, request, response| {
        response: type("application/json")
        response: status(200)
        return messagesCollection: lastN(1, -1): toJsonString()
    })
}


