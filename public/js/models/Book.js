define([
    'backbone'
], function(Backbone){

  var Book = Backbone.Model.extend({
    defaults : {
        title : "My Life",
        author : "@k33g_org"
    },
    urlRoot : "/books"
  });

  return Book;
});