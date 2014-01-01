module uploading

import m33ki.spark
import m33ki.http
import m33ki.strings

import java.io.File

----
see : https://developer.mozilla.org/en-US/docs/Web/Guide/Using_FormData_Objects
----
function main = |args| {

  initialize(): static("/samples/upload"): port(8888): error(true)

  POST("/upload", |request, response| {
    let data = DynamicObject(): files(list[])
    let files = upload(request): each(|file| {
      var uploadedFile = File(File("."): getCanonicalPath() + "/samples/upload" + "/" + file: getName()) # File
      println(uploadedFile: getAbsolutePath())
      data: files(): add(uploadedFile: getAbsolutePath())
      file: write(uploadedFile)
    })

    return """
      <style type="text/css">
        body {
            font-family: Helvetica, Arial;
            font-size: 18px;
            color: #3A4244;
            margin : 15px;
        }
      </style>
      <h1>Uploaded Files :</h1>
      <ul>
        <% data: files(): each(|file| { %>
          <li>
            <%= file %>
          </li>
        <% }) %>
      </ul>
    """
    :T("data", data)

  })


}

