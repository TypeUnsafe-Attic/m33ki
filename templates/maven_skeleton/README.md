#Your application

##Build it & run it

In the application directory, type : `mvn` then type : `java -jar m33ki-app.jar`

##Developer mode

This is the `main.golo` file :

    module main

    import m33ki.spark

    # === developer mode ===
    #import m33ki.hot # requisite for "hot reloading"

    import routes

    function main = |args| {

      # === production mode (jar) ===
      initialize(): resources("/public"): port(8888): error(true)


      # === developer mode ===
      #initialize(): static("/src/main/resources/public"): port(8888): error(true)
      #listenForChange("src/main/golo/app")
      #listenForChange("") # listen to root of the webapp

      loadRoutes()

    }

to activate the "developer mode" edit `main.golo` like this :

    module main

    import m33ki.spark

    # === developer mode ===
    import m33ki.hot # requisite for "hot reloading"

    import routes

    function main = |args| {

      # === production mode (jar) ===
      #initialize(): resources("/public"): port(8888): error(true)


      # === developer mode ===
      initialize(): static("/src/main/resources/public"): port(8888): error(true)
      listenForChange("src/main/golo/app")
      #listenForChange("") # listen to root of the webapp

      loadRoutes()

    }

Don't forget to revert it before building application jar