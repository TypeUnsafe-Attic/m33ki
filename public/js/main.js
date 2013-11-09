requirejs.config({
  baseUrl : "js/",
  paths   : {
    "domReady"      : "vendors/domReady",
    "jquery"        : "vendors/jquery.min",
    "underscore"    : "vendors/underscore-min", /*This is amd version of underscore */
    "backbone"      : "vendors/backbone-min",   /*This is amd version of backbone   */
    "text"          : "vendors/text",
    "bootstrap"     : "../bootstrap3/js/bootstrap.min",
    "lazy"          : "org.k33g/lazy"
  },
	shim: {
		"bootstrap": {
			deps: ["jquery"]
		}
	}
  /*
   http://stackoverflow.com/questions/13168816/loading-non-amd-modules-with-require-js
  */
});

require([
  'domReady',
  'application'
], function (domReady,application) {

	domReady(function () {
		//This function is called once the DOM is ready.
		//It will be safe to query the DOM and manipulate
		//DOM nodes in this function.
		$('body').css('visibility', 'visible');
		application.initialize();
	});

});