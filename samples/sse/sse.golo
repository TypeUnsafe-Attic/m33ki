module sse

import m33ki.spark
import m33ki.sse



function main = |args| {

  initialize(): static("/samples/sse"): port(8888): error(true)

  # silly sample
  GET("/sse", |request, response| {
    let sse = ServerSourceEvent(): initialize(response)
    sse: write("Hello :)")
    5: times(|id| {
        sse: write(id + " - " + java.util.Date(): toString())
        java.lang.Thread.sleep(1000_L)
    })
    sse: close()
  })

  # How to call server sent events
  #
  #  var source = new EventSource('/sse');
  #
  #  source.addEventListener('message', function(e) {
  #      console.log(e.data);
  #  }, false);
  #
  # ... source.close()


}

