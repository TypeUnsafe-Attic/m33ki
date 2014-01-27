/**
 * @jsx React.DOM
 */
define([
    'jquery'
  , 'underscore'
  , 'backbone'
  , 'react'
  , 'jsx!components/BigTitle'
  , 'jsx!components/About'
  , 'showdown' // ==> globals

], function($, _, Backbone, React, BigTitleComponent, AboutComponent){
  //"use strict";

  var Application = Backbone.Router.extend({ // application is a router

    routes : {
      "": "home",
      "help/:id" : "help",
      '*actions': 'defaultAction'
    },
    initialize : function() { //initialize models, collections and views ...
      console.log("=== Initialize application ===")
      var messageTitle = "Hello from M33ki", version="0.0 (Golo powered)";

      React.renderComponent(
        <BigTitleComponent message={messageTitle} version={version}/>,
        document.querySelector('big-title')
      );

      React.renderComponent(
        <AboutComponent docLocation="js/docs/about.md" id="about_m33ki"/>,
        document.querySelector('.about_m33ki')
      );

      React.renderComponent(
        <AboutComponent docLocation="js/docs/about.generators.md" id="about_generators"/>,
        document.querySelector('.about_generators')
      );

      React.renderComponent(
        <AboutComponent docLocation="js/docs/about.documentation.md" id="about_documentation"/>,
        document.querySelector('.about_documentation')
      );

    },
    // when routes
    home : function(){
      console.log("=== home ===");
    },
    help : function(id){
      console.log("=== help ===", id);
    },
    defaultAction: function(action) {
      console.log("defaultAction", action)
    }
  });

  return Application;
});
