module m33ki.sse

# server sent event
# http://www.sitepoint.com/implementing-push-technology-using-server-sent-events/

function ServerSourceEvent = -> DynamicObject()
    :initialize(|this, response| {
        this: response(response)
        this: response(): sparkResponse(): type("text/event-stream")
        this: response(): sparkResponse(): header("Cache-Control", "no-cache")
        this: response(): sparkResponse(): header("Connection", "keep-alive")
        this: response(): sparkResponse(): status(200)
        this: response(): sparkResponse(): raw(): setCharacterEncoding("UTF-8")
        return this
    })
    :write(|this, data| {
        let SSEData = "data:" + data + "\n\n"
        this: out(this: response(): sparkResponse(): raw(): getWriter())
        this: out(): println(SSEData)
        try {
            this: out(): flush()
        } catch(e) {
            raise("Ouch!!!")
        }
    })
    :close(|this| -> this: out(): close())



