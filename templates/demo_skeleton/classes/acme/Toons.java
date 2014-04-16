package acme;

import java.lang.Exception;
import java.lang.Integer;
import java.util.HashMap;

import com.fasterxml.jackson.databind.ObjectMapper;

public class Toons {

  public Toons() {}

  public static String all () {
    String strToons = null;
    HashMap<Integer, String> toons = new HashMap<Integer, String>();
    /*
    toons.put(1, "Babs");
    toons.put(2, "Buster");
    toons.put(3, "Elmira");
    toons.put(4, "Taz");
    */

    ObjectMapper mapper = new ObjectMapper();

    try { strToons = mapper.writeValueAsString(toons);} catch (Exception e) {}

    return strToons;
  }
  /* Golo code
  GET("/alltoons", |request, response| {
    response: type("application/json")
    return acme.Toons.all()
  })
   */
}