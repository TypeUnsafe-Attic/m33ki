module m33ki.http

----
import m33ki.http

aget(
  DynamicObject(): protocol("http"): host("localhost"): port(8888): path("/session_id"): encoding("UTF-8"),
  DynamicObject(): callbacks()
    : success(|response| {
      println(response: text())
    })
    : error(|exception|-> println("error:%s":format(exception:getMessage())))
)
----
function syncGet = |options, callbacks| {

    let url = options:protocol()+"://"+options:host()+":"+options:port()+options:path()
    println("start downloading ... : " + url )

    try {
        let obj = java.net.URL(url) # URL obj
        let con = obj:openConnection() # HttpURLConnection con (Cast?)
        #optional default is GET
        con:setRequestMethod("GET")

        if options:contentType() is null {
            options:contentType("text/plain; charset=utf-8")
        }
        con:setRequestProperty("Content-Type", options:contentType())

        #add request header
        if options:userAgent() is null {
            options:userAgent("Mozilla/5.0")
        }
        con:setRequestProperty("User-Agent", options:userAgent())

        let responseCode = con:getResponseCode() # int responseCode
        let responseMessage = con:getResponseMessage() # String responseMessage

        let responseText = java.util.Scanner(con:getInputStream(), options:encoding()):useDelimiter("\\A"):next() # String responseText



        let success = callbacks:success()

        if success isnt null {
            success(DynamicObject()
                :code(responseCode)
                :message(responseMessage)
                :text(responseText)
            )
        }

    } catch(e) {
        let error = callbacks:error()
        if error isnt null { error(e) } else { raise("Huston, we've got a problem", e) }
    }

}
