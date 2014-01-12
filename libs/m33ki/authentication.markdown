
# Documentation for `m33ki.authentication`




## Functions

### `ADMIN(users, securityKey)`

####Description

`ADMIN()` function is a quick helper to get REST routes about users management. It works with memory collections (`m33ki.collections.Collection()`) and MongoDb collections (`m33ki.mongodb.MongoCollection(MongoModel)`).

####Parameters

- `users` : this is a `m33ki.collections.Collection()`. It can mixin a `m33ki.mongodb.MongoCollection(MongoModel)`
- `securityKey` : allow encrypt/decrypt user password

####Routes

- Create user : this is a `POST` request : `/users`, you have to be login as admin
- Retrieve all users : this is a `GET` request : `/users`, you have to be login as admin
- Retrieve a user by id : this is a `GET` request : `/users/:id`, you have to be login as admin
- Retrieve a user by pseudo : this is a `GET` request : `/users/pseudo/:pseudo`, you have to be login as admin
- **(WIP:TO BE TESTED)** Update a user by id : this is a `PUT` request : `/users/:id`, you have to be login as admin
- Delete a user by id : this is a `DELETE` request : `/users/:id`, you have to be login as admin

####Calling Admin Routes with jQuery (`$.ajax`)

#####Create a user :

    $.ajax({
      type: "POST",
      url: "users",
      data: JSON.stringify({
          pseudo 		: "phil"
        ,	password 	: "phil"
        ,	create 		: true
        ,	read 		: true
        ,	update 		: true
        ,	delete 		: true
        ,	admin 		: false
      }),
      success: function(data){ console.log("success", data); },
      error: function(err){ console.log("error", err); },
      dataType: "json"
    });

#####Get all users :

    $.ajax({
      type: "GET",
      url: "users",
      success: function(users){ console.log(users) }
    });

#####Get a user by pseudo :

    $.ajax({
      type: "GET",
      url: "users/pseudo/phil",
      success: function(human){ console.log(human) }
    });

#####Update a user (you need id of user):

    $.ajax({
      type: "PUT",
      url: "users/52b6baaa3004530ace382ae1",
      data: JSON.stringify({
          pseudo 		: "phil"
        ,	password 	: "philip"
        ,	create 		: true
        ,	read 		: true
        ,	update 		: true
        ,	delete 		: true
        ,	admin 		: true
      }),
      success: function(data){ console.log("success", data); },
      error: function(err){ console.log("error", err); },
      dataType: "json"
    });

#####Delete a user (you need id of user):

    $.ajax({
      type: "DELETE",
      url: "users/52b6baaa3004530ace382ae1",
      success: function(message){ console.log(message) }
    });



### `AUTHENTICATION(users, securityKey, onLogin, onLogout, ifAuthenticated)`

####Description

`AUTHENTICATION()` method is a helper about users authentication. It creates necessary REST routes about :

- user login
- user logout
- authentication user checking

####Parameters

- `users` : this is a `m33ki.collections.Collection()`. It can mixin a `m33ki.mongodb.MongoCollection(MongoModel)`
- `securityKey` : allow encrypt/decrypt user password
- `onLogin` : callback on user login : passing parameter : `user Model()` and `authenticated` (`true` or `false`)
- `onLogout` : callback on user logout : passing parameters : `user_id`, `user_pseudo`
- `ifAuthenticated` : callback on authentication checking : passing parameters : `user_id`, `user_pseudo` | `null` and `null` if failed

####Snippet

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

####Routes

If you're using `AUTHENTICATION` then you get 3 routes :

- `/login` to connect user (`POST` request)
- `/logout` (`GET` request)
- `/authenticated` to check if current user is connected (`GET` request)

#####Calling `/login` with jQuery (`$.ajax`)

    $.ajax({
      type: "POST",
      url: "login",
      data: JSON.stringify({pseudo:"admin", password:"admin"}),
      success: function(data){ console.log("success", data); },
      error: function(err){ console.log("error", err); },
      dataType: "json"
    });

#####Calling `/logout` with jQuery (`$.ajax`)

    $.get("authenticated", function(data){ console.log(data); })

    //return Object {authenticated: true} (or false) + pseudo if true (null if false)

#####Calling `/authenticated` with jQuery (`$.ajax`)

    $.get("logout", function(data){ console.log(data); })



### `Session(request)`

####Description

`Session(req)` function returns a DynamicObject with properties of current session (Spark request: session()).

*Remark: if session object doesn't exist, it will be created*

####Parameter

You have to pass the Spark request object to `Session()` function

####Properties of Session DynamicObject

Each property of the DynamicObject is a session attribute :

- `id()`
- `pseudo()`
- `read()`
- `create()`
- `update()`
- `delete()`
- `admin()`



### `User()`

####Description

`User()` function returns a `m33ki.models.Model()` with default `fields(map[])` :

    map[
        ["pseudo", "john"]
      , ["firstName", "John"]
      , ["lastName", "Doe"]
      , ["password", null]
      , ["read", true]
      , ["create", false]
      , ["update", false]
      , ["delete", false]
      , ["admin", false]
    ]

####User Methods (+ Model methods)

- `rights(canRead, canCreate, canUpdate, canDelete)` : set fields values of `read, create, update, delete`



### `decrypt(something, withSecurityKey)`

####Description

`decrypt(something, withSecurityKey)` function returns a decrypted string

####Parameters

- `something` : String to decrypt
- `withSecurityKey` : security key


### `encrypt(something, withSecurityKey)`

####Description

`encrypt(something, withSecurityKey)` function returns an encrypted string

####Parameters

- `something` : String to encrypt
- `withSecurityKey` : security key



## Augmentations


## Structs

