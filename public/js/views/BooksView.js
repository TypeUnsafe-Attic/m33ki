define([
  'jquery',
  'underscore',
  'backbone',
  'lazy',
  'text!templates/books.tpl.html'
], function($, _, Backbone, Lazy, booksTpl){

  var BooksView = Lazy.View.extend({
    properties : {
      el : ".books-view",
      template : booksTpl,
      alias : "books" // data alias for the template
    },
    events: {
      'click .close-list': 'close'
    }
  });
  return BooksView;
});