define([
    'backbone',
    'models/Book'
], function(Backbone, Book){

  var Books = Backbone.Collection.extend({
    model : Book,
    url : "/books"
  });

  return Books
});