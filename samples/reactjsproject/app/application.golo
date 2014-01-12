module application

# === Application configuration ==== ...

function getDBName = -> "cuicuidb"

function getSecurityKey = -> "ultimatelanguageisgolo"

function getPort = -> 8888

function getPublic = -> "/public"

function getMailConfig = ->
  DynamicObject()
    : hostName("smtp.googlemail.com")
    : smtpPort(465)
    : user("me@gmail.com")
    : password("xxx")
