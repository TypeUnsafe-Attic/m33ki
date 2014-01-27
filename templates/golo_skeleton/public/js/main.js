requirejs.config({
  baseUrl : "js/",
  paths   : {
    "domReady"      : "vendors/domReady",
    "jquery"        : "vendors/jquery.min",
    "underscore"    : "vendors/underscore-min", /*This is amd version of underscore */
    "backbone"      : "vendors/backbone-min",   /*This is amd version of backbone   */
    "text"          : "vendors/text",
    "showdown"      : "vendors/showdown",
    "jsx"           : "vendors/jsx",
    "JSXTransformer": "vendors/JSXTransformer",
    "react"         : "vendors/react.min"
  },
  shim: {
    "bootstrap": {
      deps: ["jquery"]
    },
    "showdown": {
      "exports": "Showdown"   //attaches "Showdown" to the window object
    }
  }
});

require([
  'domReady',
  'jsx!application/Application',
  'backbone'
], function (domReady, Application, Backbone) {

  domReady(function () {
    console.log("DOM is ready!");
    //$('body').css('visibility', 'visible');
    window.App = new Application();
    Backbone.history.start();
  });

});


