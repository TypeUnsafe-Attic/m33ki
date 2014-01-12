module uploading

import m33ki.spark
import m33ki.http
import m33ki.jackson

import java.io.File

----
see : https://developer.mozilla.org/en-US/docs/Web/Guide/Using_FormData_Objects
----
function main = |args| {

  initialize(): static("/samples/upload"): port(8888): error(true)

  POST("/upload", |request, response| {
    response: type("application/json")
    let data = DynamicObject(): files(map[])

    let files = upload(request): each(|file| {
      var uploadedFile = File(File("."): getCanonicalPath() + "/samples/upload" + "/files/" + file: getName()) # File
      println(uploadedFile: getAbsolutePath())
      data: files(): add(file: getName(), uploadedFile: getAbsolutePath())
      file: write(uploadedFile)
    })

    return Json(): toJsonString(data: files())

  })

}

