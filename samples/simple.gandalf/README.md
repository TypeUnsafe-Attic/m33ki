#Gandalf module

##Run sample :

`golo golo --classpath jars/*.jar --files libs/*.golo samples/simple.gandalf/simple.golo`

>>WIP : this sample is using "memory" collections, MongoDb version has not been tested yet

##Create a Gandalf Application

```coffeescript
module simple

import m33ki.spark
import m33ki.collections
import m33ki.gandalf

function main = |args| {

  # static assets
  static("/samples/simple.gandalf/public")
  port(8888)

  CRUD(map[
      ["humans", Collection()]
    , ["animals", Collection()]
  ])
}
```

###What can i do now?

####Add new human (or animal, change "humans" by "animals" on url)

```javascript
$.ajax({
  type: "POST",
  url: "humans",
  data: JSON.stringify({firstName : "Bob", lastName : "Morane"}),
  dataType: "json",
  success: function(human){ console.log(human) }
});
```

####Get a human by id

```javascript
$.ajax({
  type: "GET",
  url: "humans/ff06fc5a-d779-4e8a-810c-cf1aeeffd5b8",
  success: function(human){ console.log(human) }
});
```

####Get all humans

```javascript
$.ajax({
  type: "GET",
  url: "humans",
  success: function(humans){ console.log(humans) }
});
```

####Update a human

```javascript
$.ajax({
  type: "PUT",
  url: "humans/ff06fc5a-d779-4e8a-810c-cf1aeeffd5b8",
  data: JSON.stringify({firstName : "BOB", lastName : "MORANE"}),
  dataType: "json",
  success: function(human){ console.log(human) }
});
```

####Delete a human

```javascript
$.ajax({
  type: "DELETE",
  url: "humans/ff06fc5a-d779-4e8a-810c-cf1aeeffd5b8",
  success: function(message){ console.log(message) }
});
```

####Find a human

```javascript
$.get("humans/find/lastName/wayne", function(humans){ console.log(humans); })
```

##Create a "secured" Gandalf application

You've have to only add a "users" collection :

```coffeescript
module simple

import m33ki.spark
import m33ki.collections
import m33ki.gandalf
import m33ki.authentication

function main = |args| {

  let users = Collection()

  users
    : addItem(User(): pseudo("admin"): pwd("admin"): rights(true, true, true, true): admin(true))
    : addItem(User(): pseudo("bob"): pwd("bob"): rights(true, true, true, false))

  # rights (read, create, update, delete)

  # static assets
  static("/samples/simple.gandalf/public")
  port(8888)

  CRUD(map[
      ["users", users]          # "users" key activates security
    , ["humans", Collection()]
    , ["animals", Collection()]
  ])
}
```

###What can i do now?

- All users can read and find humans or animals (GET requests)
- Nobody can access users collection except administrator users (`admin(true)`)
- Administrator users can access to users collection and add, update, delete or get all users
- A user can create, update or delete if he has the appropriate rights

####Authentication : Login

```javascript
$.ajax({
  type: "POST",
  url: "login",
  data: JSON.stringify({pseudo:"admin", password:"admin"}),
  success: function(data){ console.log("success", data); },
  error: function(err){ console.log("error", err); },
  dataType: "json"
});
```

####Authentication : I am authenticated ?

```javascript
$.get("authenticated", function(data){ console.log(data); })

//return Object {authenticated: true} (or false)
```

####Authentication : Logout

```javascript
$.get("logout", function(data){ console.log(data); })
```

###I am administrator, what can i do?

####Create a user :

```javascript
$.ajax({
  type: "POST",
  url: "users",
  data: JSON.stringify({
      pseudo 		: "phil"
    ,	password 	: "phil"
    ,	create 		: true
    ,	read 		  : true
    ,	update 		: true
    ,	delete 		: true
    ,	admin 		: false
  }),
  success: function(data){ console.log("success", data); },
  error: function(err){ console.log("error", err); },
  dataType: "json"
});
```

####Get all users :

```javascript
$.ajax({
  type: "GET",
  url: "users",
  success: function(users){ console.log(users) }
});
```

####Get a user by pseudo :

```javascript
$.ajax({
  type: "GET",
  url: "users/phil",
  success: function(human){ console.log(human) }
});
```

####Update a user :

```javascript
$.ajax({
  type: "PUT",
  url: "users/phil",
  data: JSON.stringify({
      pseudo 		: "phil"
    ,	password 	: "philip"
    ,	create 		: true
    ,	read 		  : true
    ,	update 		: true
    ,	delete 		: true
    ,	admin 		: true
  }),
  success: function(data){ console.log("success", data); },
  error: function(err){ console.log("error", err); },
  dataType: "json"
});
```

####Delete a user :

```javascript
$.ajax({
  type: "DELETE",
  url: "users/phil",
  success: function(message){ console.log(message) }
});
``
