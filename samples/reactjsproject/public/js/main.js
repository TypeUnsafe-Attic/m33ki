requirejs.config({
  //deps : ["main"],
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
    "showdown": {
      "exports": "Showdown"   //attaches "Showdown" to the window object
    }
  }
});

/*
JSX :
 http://blog.mayflower.de/3937-Backbone-React.html
 https://github.com/seiffert/blog-articles/tree/master/pimp-my-backbone.view
 https://github.com/seiffert/require-jsx
 */


require([
  'domReady',
  'jsx!application/Application',
  'backbone'
], function (domReady, Application, Backbone) {

  domReady(function () {
    //This function is called once the DOM is ready.
    //It will be safe to query the DOM and manipulate
    //DOM nodes in this function.
    //$('body').css('visibility', 'visible');
    window.App = new Application();

    console.log(App)

    Backbone.history.start();
  });

});