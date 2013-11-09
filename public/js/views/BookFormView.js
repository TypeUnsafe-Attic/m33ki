define([
  'jquery',
  'underscore',
  'backbone',
  'lazy',
  'text!templates/book.form.tpl.html'
], function($, _, Backbone, Lazy, bookFormTpl){

  var BookFormView = Lazy.View.extend({
    properties : {
      el : ".book-form-view",
      alias : "book", // data alias for the template,
      template : bookFormTpl
    },
    events : {
      'click .add-book': 'add',
      'change input': 'change'
    },
    add : function() {
      var currentForm = this;
      this.model.set({
        title : this.getValue(".book-title"),
        author :this.getValue(".book-author")
      });

      var newBook = this.model.clone()

      newBook.save().done(function(){
        currentForm.attributes.collection.add(newBook);
        currentForm.model.set({title:"title", author:"author"});
        currentForm.render()
      })

      /*
      this.attributes.collection.add(newBook);
      this.model.set({title:"title", author:"author"});
      this.render()
      */
    },
    change : function() {}
  });

  return BookFormView;
});


