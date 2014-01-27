#Backbone Models & Collections
module bmc

function template_model = ->
"""<%@params infos %>/*--- <%= infos: model_name() %> Model ---*/
define([
    'backbone'
], function(Backbone){

    var <%= infos: model_name() %> = Backbone.Model.extend({
        defaults : function (){
          return {
            <%= infos: fields(): join(",") %>
          }
        },
        urlRoot : "<%= infos: model_name(): toLowerCase() %>s"
    });

    return <%= infos: model_name() %>;
});
/* How to use it
define([
  'jquery',
  'underscore',
  'backbone',
  'models/<%= infos: model_name() %>',
  'models/<%= infos: model_name() %>s'
], function($, _, Backbone, <%= infos: model_name() %>, <%= infos: model_name() %>s) {

    var Application = {};

    return Application;
});
*/
"""

function template_collection = ->
"""<%@params infos %>/*--- <%= infos: model_name() %>s Collection ---*/
define([
    'backbone',
    'models/<%= infos: model_name() %>'
], function(Backbone, <%= infos: model_name() %>){

    var <%= infos: model_name() %>s = Backbone.Collection.extend({
        model : <%= infos: model_name() %>,
        url : "<%= infos: model_name(): toLowerCase() %>s"
    });

    return <%= infos: model_name() %>s;
});
/* How to use it
define([
  'jquery',
  'underscore',
  'backbone',
  'models/<%= infos: model_name() %>',
  'models/<%= infos: model_name() %>s'
], function($, _, Backbone, <%= infos: model_name() %>, <%= infos: model_name() %>s) {

    var Application = {};

    return Application;
});
*/
"""

function template_list = ->
"""<%@params infos %>/** @jsx React.DOM */
define([
  "react",
  "models/<%= infos: model_name() %>",
  "models/<%= infos: model_name() %>s"
], function (React, <%= infos: model_name() %>, <%= infos: model_name() %>s) {
  /*--- <%= infos: model_name() %>s List ---*/
  var <%= infos: model_name() %>sList = React.createClass({

    getInitialState: function() {
      return {data : [], message : "..."};
    },
    getAll<%= infos: model_name() %>s : function() {
      var <%= infos: model_name(): toLowerCase() %>sCollection = new <%= infos: model_name() %>s();

      <%= infos: model_name(): toLowerCase() %>sCollection.fetch({
        success : function(data) {
          this.setState({data : data.toJSON(), message : Date()});
        }.bind(this),
        error : function(err) {
          this.setState({
            message  : err.responseText + " " + err.statusText
          });
        }
      })
    },
    componentWillMount: function() {
      this.getAll<%= infos: model_name() %>s();
      setInterval(this.getAll<%= infos: model_name() %>s, this.props.pollInterval);
    },

    componentDidMount: function() {
      var Router = Backbone.Router.extend({
        routes : {
          "delete_<%= infos: model_name(): toLowerCase() %>/:id" : "delete<%= infos: model_name() %>"
        },
        initialize : function() {

        },
        delete<%= infos: model_name() %> : function(id){
          console.log("=== delete <%= infos: model_name() %> ===", id);
          var tmp<%= infos: model_name() %> = new <%= infos: model_name() %>({id:id}).destroy();
          this.navigate('/');
        }
      });
      this.router = new Router()
    },

    styles : {
      ul: {
        class:"square"
      }
    },
    render: function() {

      var <%= infos: model_name(): toLowerCase() %>sNodes = this.state.data.map(function(<%= infos: model_name(): toLowerCase() %>){
        var deleteLink = "#delete_<%= infos: model_name(): toLowerCase() %>/" + <%= infos: model_name(): toLowerCase() %>.id;
        return <li>
          <% infos: fields_and_default(): each(|field, fieldValue|{ %> {<%= infos: model_name(): toLowerCase() %>.<%= field %>} {"\u00A0"}<% }) %><a href={deleteLink}>delete</a>
        </li>;
      });

      return (
        <div><h3><%= infos: model_name() %>s List</h3>
          <strong>{this.state.message}</strong>
          <ul className={this.styles.ul.class}>
            {<%= infos: model_name(): toLowerCase() %>sNodes}
          </ul>
        </div>
      );

    }
  });
  return <%= infos: model_name() %>sList;

});
/* How to use it

'jsx!components/<%= infos: model_name() %>sList'

React.renderComponent(
  <<%= infos: model_name() %>sList pollInterval={500}/>,
  document.querySelector('.<%= infos: model_name(): toLowerCase() %>s-list')
);
*/
"""

function template_form = ->
"""<%@params infos %>/** @jsx React.DOM */
define([
  "react",
  "models/<%= infos: model_name() %>",
  "models/<%= infos: model_name() %>s"
], function (React, <%= infos: model_name() %>, <%= infos: model_name() %>s) {
  /*--- <%= infos: model_name() %> Form ---*/
  var <%= infos: model_name() %>Form = React.createClass({

    getInitialState: function() {
      return {data : [], message : ""};
    },
    componentDidMount: function() {},
    componentWillMount: function() {},

    handleSubmit : function() {

      <% infos: fields_and_default(): each(|field, fieldValue|{ %>var <%= field %> = this.refs.<%= field %>.getDOMNode().value.trim();
      <% }) %>
      <% infos: fields_and_default(): each(|field, fieldValue|{ %>if (!<%= field %>) {return false;}
      <% }) %>
      this.setState({
        message : "Please wait ..."
      });

      var tmp<%= infos: model_name() %> = new <%= infos: model_name() %>({<%= infos: fields_for_form(): join(",") %>}).save({},{
        success: function(data) {
          this.setState({
            message : data.id + " added!"
          });

          <% infos: fields_and_default(): each(|field, fieldValue|{ %>this.refs.<%= field %>.getDOMNode().value = '';
          <% }) %>
          /*
          <% infos: fields_and_default(): each(|field, fieldValue|{ %>this.refs.<%= field %>.getDOMNode().focus();
          <% }) %>
          */

        }.bind(this),
        error : function(err) {
          this.setState({
            message  : err.responseText + " " + err.statusText
          });
        }
      });

      return false;
    },

    styles : {},

    render: function() {

      return (
        <div>
        <h3><%= infos: model_name() %> Form</h3>
        <form onSubmit={this.handleSubmit}>
          <% infos: fields_and_default(): each(|field, fieldValue|{ %><input type="text" placeholder="<%= field %>" ref="<%= field %>"/>
          <% }) %>
          <input type="submit" value="Add <%= infos: model_name() %>" />
          <br></br>
          <strong>{this.state.message}</strong>
        </form>
        </div>
      );

    }
  });
  return <%= infos: model_name() %>Form;

});
/* How to use it

'jsx!components/<%= infos: model_name() %>Form'

React.renderComponent(
  <<%= infos: model_name() %>Form/>,
  document.querySelector('.<%= infos: model_name(): toLowerCase() %>-form')
);
*/

"""

function generator = |applicationDirectory| {

  println("=== Backbone Models & Collections ===")
  println("")

  let model_name = readln("Model name ? ")

  let infos = DynamicObject()
      : model_name(model_name)

  let string_fields = readln("""Fields names and default values (firstName:"John",lastName:"Doe", ...)? """)

  let fields_and_default = map[]
  let fields = string_fields: split(","): asList()

  fields: each(|field| {
    let fieldInfos = field: split(":")
    fields_and_default: add(fieldInfos: get(0): trim(), fieldInfos: get(1): trim())
  })

  infos: fields_and_default(fields_and_default): fields(fields)

  let fields_for_form = list[]
  fields_and_default: each(|fieldName, fieldValue|{
    fields_for_form: append(fieldName + " : " + fieldName)
    #println(fieldName)
  })

  infos: fields_for_form(fields_for_form)

  # generate model source code
  let output_model = gololang.TemplateEngine(): compile(template_model())
  let model_source_code = output_model(infos)
  textToFile(model_source_code, applicationDirectory+"/public/js/models/"+model_name+".js")
  println(applicationDirectory+"/public/models/"+model_name+".js")

  # generate collection source code
  let output_collection = gololang.TemplateEngine(): compile(template_collection())
  let collection_source_code = output_collection(infos)
  textToFile(collection_source_code, applicationDirectory+"/public/js/models/"+model_name+"s.js")
  println(applicationDirectory+"/public/models/"+model_name+"s.js")

  # generate list component source code
  let output_list_component = gololang.TemplateEngine(): compile(template_list())
  let component_list_source_code = output_list_component(infos)
  textToFile(component_list_source_code, applicationDirectory+"/public/js/components/"+model_name+"sList.js")
  println(applicationDirectory+"/public/components/"+model_name+"sList.js")

  # generate form component source code
  let output_form_component = gololang.TemplateEngine(): compile(template_form())
  let component_form_source_code = output_form_component(infos)
  textToFile(component_form_source_code, applicationDirectory+"/public/js/components/"+model_name+"Form.js")
  println(applicationDirectory+"/public/components/"+model_name+"Form.js")

}