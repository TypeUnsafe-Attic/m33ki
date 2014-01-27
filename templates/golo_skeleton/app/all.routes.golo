module all.routes

import generated.routes

function defineRoutes = {
  try {
    defineAllGeneratedRoutes()
  } finally {
    println("....")
  }
}

