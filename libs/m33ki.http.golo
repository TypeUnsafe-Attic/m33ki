module m33ki.http

import org.apache.commons.fileupload.servlet.ServletFileUpload
import org.apache.commons.fileupload.disk.DiskFileItemFactory

function upload = |request| {
  let factory = DiskFileItemFactory() # FileItemFactory
  let upload = ServletFileUpload(factory) # ServletFileUpload
  try {
    let items = upload: parseRequest(request: raw())
    return items: filter(|item| -> item: isFormField() isnt true)
  } catch(e) {
    e: printStackTrace()
  }
}
