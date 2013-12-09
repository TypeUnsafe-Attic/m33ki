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
      'click .close-list': 'close',
      'click a' : 'linkClicked'
    },
    linkClicked : function(e) {
      //console.log(this.getHashValue(e))
      //console.log(this.collection.get(this.getHashValue(e)))

      this.collection.get(this.getHashValue(e)).destroy()
        .done(function(data){
          console.log(data);
        })
        .fail(function(err){
          console.log(err);
        });


    }
  });
  return BooksView;
});