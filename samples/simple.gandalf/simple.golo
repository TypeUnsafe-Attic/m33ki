module simple

import m33ki.spark
import m33ki.collections
import m33ki.gandalf
import m33ki.authentication

function main = |args| {
  let securityKey = "ultimatelanguageisgolo"
  let users = Collection()

  #User is a model, defined in m33ki.authentication
  users
    : addItem(User(): pseudo("admin"): pwd(encrypt("admin", securityKey)): rights(true, true, true, true): admin(true))
    : addItem(User(): pseudo("bob"): pwd(encrypt("hello", securityKey)): rights(true, false, false, false))
    : addItem(User(): pseudo("sam"): pwd(encrypt("salut", securityKey)): rights(true, false, false, false))

  #initialize(): static("/samples/simple.gandalf/public"): port(8888): error(true)
  initialize(): static("/public"): port(8888): error(true): listenForChange("")

  CRUD(map[
      ["users", users]          # "users" key activates security
    , ["humans", Collection()]
    , ["animals", Collection()]
  ], securityKey)
}

