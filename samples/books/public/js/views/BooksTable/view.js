define([
  'jquery',
  'underscore',
  'backbone',
  'lazy',
  'text!./tpl.html'
], function($, _, Backbone, Lazy, booksTpl){

  var BooksView = Lazy.View.extend({
    properties : function() {return{
      el : ".books-view",
      template : booksTpl,
      alias : "books" // data alias for the template
    }},
    events: {
      'click .close-list': 'close'
    }
  });
  return BooksView;
});