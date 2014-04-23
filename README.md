#M33ki

>The !(not)Opinionated Web Framework *(by TypeUnSafe inc.)*

![...](meekilogo.png)

>Any Resemblance to Existing Framework is Purely Coincidental

*M33ki Framework makes it easy to build web applications with Golo & Java.*

M33ki is based on a lightweight, stateless or stateful (as you want) , web-friendly architecture.

Built on Golo and SparkJava *(and some other libraries)*, M33ki provides minimal resource consumption (CPU, memory, threads) for embedded web server.

##Developer friendly.

Make your changes and simply hit refresh! All you need is a browser and a text editor.

###Getting started with Golo

- open a terminal
- type `m33ki`
- type your application name, ie `myapp`
- choose the kind of project : `1`
- that's all, go to the application directory : `cd myapp` and run it `./go.sh`

Terminal :

       _____  ________ ________  __   .__
      /     \ \_____  \\_____  \|  | _|__|
     /  \ /  \  _(__  <  _(__  <|  |/ /  |
    /    Y    \/       \/       \    <|  |
    \____|__  /______  /______  /__|_ \__|
            \/       \/       \/     \/
      WebApp server Golo powered (c) @k33g_org

    OS : mac os x
    Application name?>myapp
    Creating myapp application
    1- copy /Users/k33g_org/Dropbox/Public/TYPEUNSAFE/m33ki/jars to /Users/k33g_org/Dropbox/Public/myapp
    2- copy /Users/k33g_org/Dropbox/Public/TYPEUNSAFE/m33ki/libs to /Users/k33g_org/Dropbox/Public/myapp

    reading configuration file
    What kind of application ?
    1- Golo Skeleton project
    2- Hybrid project (Java + Golo)
    number?>1
    Creating Golo Skeleton project ...

    myapp application has been created
    Last steps :
    - type : cd myapp

    Now, to start the application just type : ./go.sh
    Have fun!

More explanations to come : WIP

###Getting started with Java

- open a terminal
- type `m33ki`
- type your application name, ie `myapp`
- choose the kind of project : `2`
- that's all, go to the application directory : `cd myapp` and run it `./go.sh`

###Hi! An "obliging" web's scaffolding tool

see : [https://github.com/k33g/hi](https://github.com/k33g/hi)

Hi comes with a application generator for M33ki

>You can add your own generators. See `generators` directory


##Golo Application structure

WIP

##Hybrid (Java+Golo) Application structure

WIP

##Modern web & mobile.

M33ki was built for needs of modern web & mobile apps.

- RESTful by default
- JSON is a first class citizen
- Websockets, EventSource (Server Sent Events)
- NoSQL (MongoDb & Redis)

###REST Example

```coffeescript
# Create a model
POST("/models", |request, response| {
  println(request: body())
  response: json(Json(): toJsonString(map[["message", "this is a POST request"]])): status(201) # 201: created
})

# Retrieve all models
GET("/models", |request, response| {
  response: json(Json(): toJsonString(map[["message", "this is a GET request"]]))
})

# Retrieve a model by id
GET("/models/:id", |request, response| {
  let id = request: params(":id")
  response: json(Json(): toJsonString(map[["message", "this is a GET request with id="+id]]))
})

# Update model
PUT("/models/:id", |request, response| {
  println(request: body())
  let id = request: params(":id")
  response: json(return Json(): toJsonString(map[["message", "this is a PUT request with id="+id]]))
})

# Delete model
DELETE("/models/:id", |request, response| {
  let id = request: params(":id")
  response: json(return Json(): toJsonString(map[["message", "this is a DELETE request with id="+id]]))
})
```

##Asynchronous model ... if you want

###Promises (hopes)

WIP

###Actors

WIP


##Install M33ki

###Dependencies

You have to install Golo and set GOLO_HOME to PATH

###Linux

    # 1- clone m33ki repository in a directory
    git clone https://github.com/TypeUnsafe/m33ki.git

    # 2- edit .bashrc
    pico ~/.bashrc

    # 3- Then :
    export GOLO_HOME="$HOME/golo-directory/"
    export PATH=$PATH:$GOLO_HOME/bin

    export PATH=$PATH:$HOME/directory/m33ki

###OSX

    # 1- clone m33ki repository in a directory
    git clone https://github.com/TypeUnsafe/m33ki.git

    # 2- edit .bash_profile
    sudo pico ~/.bash_profile

    # 3- Then :
    GOLO_HOME=/golo-directory/
    export GOLO_HOME
    export PATH=$PATH:$GOLO_HOME/bin

    M33KI_HOME=/directory/m33ki
    export M33KI_HOME
    export PATH=$PATH:$M33KI_HOME
    
###OSX with [Homebrew](https://github.com/TypeUnsafe/homebrew-golo)
    
    # 1- tap the typeunsafe repository (only once)
    brew tap TypeUnsafe/golo
    
    # 2- install the m33ki formula (depends on golo)
    brew install --HEAD m33ki
    
###Windows

  Set System Variables in Configuration Panel.

##Create an application

- run console : type `m33ki`
- answer the questions (application name, kind of application)
- that's all
- `cd <name of the application>`
- run your application : type `./go.sh` (OSX & Linux) or `go.bat` (Windows)

##Extend your application

Each M33ki application has a `/jars` directory. You just need to copy the jar file you need in this directory, and then you can use it with Golo and/or Java?

##Extend M33ki

###Jars

    W.I.P.

###Templates

You can create project template in `/templates` directory of M33ki distribution. Do not forget to change the `m33ki.json` file to declare your new project :

    {
        "1" : ["Simple project","simple"]
      , "2" : ["REST project", "rest"]
      , "3" : ["Hybrid project (Java + Golo)", "hybrid"]
    }

##W.I.P.

- Documentation
- ...
