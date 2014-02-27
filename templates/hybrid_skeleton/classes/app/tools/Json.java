package app.tools;

// see : https://github.com/playframework/playframework/blob/master/framework/src/play-json/src/main/java/play/libs/Json.java

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.ObjectNode;

/*--- Helper functions to handle JsonNode values. ---*/
public class Json {

  /*--- Convert an object to JsonNode ---*/
  public static JsonNode toJson(final Object data) {
    try {
      return (new ObjectMapper()).valueToTree(data);
    } catch(Exception e) {
      throw new RuntimeException(e);
    }
  }
  /*--- Convert a JsonNode to a Java value ---*/
  public static <A> A fromJson(JsonNode json, Class<A> clazz) {
    try {
      return (new ObjectMapper()).treeToValue(json, clazz);
    } catch(Exception e) {
      throw new RuntimeException(e);
    }
  }
  /*--- Convert a JsonNode to its string representation ---*/
  public static String stringify(JsonNode json) {
    return json.toString();
  }

  /*--- Convert an Object to its JsonString representation ---*/
  public static String stringify(Object data) {
    JsonNode jsonNode =  Json.toJson(data);
    return jsonNode.toString();
  }


  /*--- Parse a String representing a json, and return it as a JsonNode ---*/
  public static JsonNode parse(String src) {
    try {
      return (new ObjectMapper()).readValue(src, JsonNode.class);
    } catch(Throwable t) {
      throw new RuntimeException(t);
    }
  }

}