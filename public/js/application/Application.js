define([
  'jquery',
  'underscore',
  'backbone',
  'bootstrap',
  'models/Book',
  'models/Books',
  'views/BooksView',
  'views/BookFormView',
  'lazy'
], function(
		$, _, Backbone
	, bootstrap
	, Book, Books
	, BooksView, BookFormView
  , Lazy)
{

  var Application = Lazy.Application.extend({ // application is a router

    routes : {
        "help": "help"    // #help
      , '*actions': 'defaultAction'
    },

    initialize : function() { //initialize models, collections and views ...
      this.books = new Books(); // books collection
      this.booksView = new BooksView({ collection : this.books }); // books list

      this.bookFormView = new BookFormView({ // book form
        model : new Book(),
        attributes : {collection : this.books }
      });

      this.listenTo(this.bookFormView, "rendered", this.sendMessage)

      this.books.fetch();

      this.bookFormView.render();

      /*this.router.on('route:defaultAction', function (actions) {
        console.log("hello", actions)
      });
      */

    },
    help : function(){
      console.log("=== HELP ===");
    },
    defaultAction: function(action) {
      console.log("defaultAction", action)
    },
    sendMessage : function() {
        $(".this-is-a-message").html("Books are loaded, so, all is OK, have fun!");
    }
  });

    return Application;
});
