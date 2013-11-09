define([
    'application/Application'
], function (Application) {

    return {
        initialize: function () {
	        new Application();
	        Backbone.history.start();
        }
    };
});



