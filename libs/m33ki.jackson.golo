module m33ki.jackson

import com.fasterxml.jackson.core.JsonProcessingException
import com.fasterxml.jackson.databind.JsonNode
import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.node.ObjectNode

struct Json = { _foo }

augment Json {
  function toJsonString = |this, data| {
    let mapper = ObjectMapper()
    return mapper: writeValueAsString(data)
  }
  function parse = |this, src| {
    # Parse a String representing a json, and return it as a JsonNode.
    # Parameter : String
    # Return value : JsonNode
    let mapper = ObjectMapper()
    return mapper: readValue(src, JsonNode.class)
  }
  function fromJson = |this, json, clazz| {
    # Convert a JsonNode to a Java value
    # Parameter : json Json value to convert : JsonNode
    # Parameter : clazz Expected Java value type : Class<A> clazz
    # Return value : A
    let mapper = ObjectMapper()
    return mapper: treeToValue(json, clazz)
  }
  function toJson = |this, data| {
    # Convert an object to JsonNode
    # Parameter data Value to convert in Json : Object
    # Return value : JsonNode
    let mapper = ObjectMapper()
    return mapper: valueToTree(data)
  }
  function stringify = |this, json| {
    # Convert a JsonNode to its string representation.
    # Parameter : JsonNode
    # Return value : String
    return json: toString()
  }
  function toHashMap = |this, something| {
    let jsonNode = this: parse(something)
    let hMap = this: fromJson(jsonNode, java.util.HashMap.class)
    return hMap
  }
  function toTreeMap = |this, something| {
    let jsonNode = this: parse(something)
    let treeMap = this: fromJson(jsonNode, java.util.TreeMap.class)
    return treeMap
  }
  function message = |this, message| {
    return this: toJsonString(map[["message", message]])
  }
}

