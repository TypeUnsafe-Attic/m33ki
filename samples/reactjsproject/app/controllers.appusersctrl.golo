module controllers.appusersctrl

import application            # getSecurityKey()
import models.appuser
import m33ki.authentication   # encrypt
import m33ki.jackson
import m33ki.strings

import m33ki.collections

import org.apache.commons.mail.HtmlEmail
import org.apache.commons.mail.DefaultAuthenticator

function AppUsersCtrl = |usersCollection| {

  return DynamicObject()
    : define("findOrCreateUsers", |this| {
       let findOrCreateUser = |pseudo| {
         let users =  usersCollection: find("pseudo", pseudo)
         if users: size() > 0 {
           let user = users: toModelsList(): getFirst()
           println("--> user exists!!! : " + user: toJsonString())
         } else {
           # create user
           println("--> user creation ...")
           let newUser = usersCollection: model()
             : pwd(encrypt(pseudo, getSecurityKey()))
             : pseudo(pseudo)
             : admin(false)
           newUser: create()
           println("--> user created : " + newUser: toJsonString())
         }
       }

       findOrCreateUser("albator")
       findOrCreateUser("actarus")
       findOrCreateUser("alcor")
       findOrCreateUser("venusia")


    })
    : define("findOrCreateAdmin", |this| {
       let admins = usersCollection: find("pseudo", "admin")

       if admins: size() > 0 {
         let admin = admins: toModelsList(): getFirst()
         println("--> Admin exists!!! : " + admin: toJsonString())
       } else {
         # create a default admin
         println("--> Admin creation ...")
         let newAdmin = usersCollection: model()
           : pwd(encrypt("admin", getSecurityKey()))
           : pseudo("admin")
           : admin(true)
           : canRead(true)
           : canCreate(true)
           : canUpdate(true)
           : canDelete(true)

         newAdmin: create()
         println("--> Admin created : " + newAdmin: toJsonString())
       }

    })
    : define("signUp", |this, request, response| { # POST request
     # TODO: upload avatar
     response: type("application/json")

     let model = usersCollection: model(): fromJsonString(request: body())

     let pseudo = model: getField("pseudo")
     let email = model: getField("email")
     let password = model: getField("password")
     let encryptPassword = encrypt(password, getSecurityKey())
     #TODO: verify that all data are OK
     #TODO: verify if user exists

     model: setField("password", encryptPassword)

     this: sendConfirmationMail(email, java.net.URLEncoder.encode(model: toJsonString()))

     return Json(): toJsonString(map[["message", "mail send, verify your box"]])

    })
    : define("sendConfirmationMail", |this, mailAddress, url_parameter| {
       #TODO : a better mail ;)
       let email = HtmlEmail()
       email: setHostName(getMailConfig(): hostName())
       email: setSmtpPort(getMailConfig(): smtpPort())
       email: setAuthenticator(DefaultAuthenticator(getMailConfig(): user(), getMailConfig(): password()))
       email: setSSLOnConnect(true)
       email: setFrom("donotreplye@gmail.com")
       email: setSubject("CuiCui Inscription")
       email: setHtmlMsg("Click <a href='http://localhost:8888/confirm/"+url_parameter+"'>cuicui.com</href>")
       email: setMsg("Click <a href='http://localhost:8888/confirm/"+url_parameter+"'>cuicui.com</href>")
       email: addTo(mailAddress)
       email: send()
       return true
    })
    : define("createNewUser", |this, request, response| {
       response: type("text/html")
       response: status(200)

       let jsonString = java.net.URLDecoder.decode(request: params(":who"))
       println(jsonString)

       let model = usersCollection: model(): fromJsonString(jsonString)

       model: admin(false)
       model: create() # insert model in collection

       return """
         <h1>Welcome! <%= model: getField("email") %> </h1>
         <a href="/">Go Home and Sign In</a>
       """:
       T("model", model)
       #return Json(): toJsonString(map[["message", "ReactJS project"]])

    })
    : define("getAllUsers", |this, request, response| {
       response: type("application/json")
       let appusersCollection = usersCollection: fetch()

       if appusersCollection: size() > 0 {
         let memUsersCollection = Collection()
         appusersCollection: forEach(|model|{
           # add copy of user but delete password
           memUsersCollection: addItem(model: copy(): deleteField("password"))
         })
         response: status(200)
         return memUsersCollection: toJsonString()
       } else {
         #raise("Huston, we've got a problem")
         response: status(500) #
         return Json(): message("Huston, we've got a problem")
       }
    })
}



  # Try this in console mode (with browser) to be authenticated
  # $.ajax({
  #   type: "POST",
  #   url: "login",
  #   data: JSON.stringify({pseudo:"admin", password:"admin"}),
  #   success: function(data){ console.log("success", data); },
  #   error: function(err){ console.log("error", err); },
  #   dataType: "json"
  # });