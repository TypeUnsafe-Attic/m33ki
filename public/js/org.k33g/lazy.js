// lazy.view.js


/* --- Documentation ---

 Lazy.View.extend({
 properties : {
 el : ".component-view",
 template : componentsTpl,
 alias : "components"
 },
 lazyTemplate : function () { ... }
 })

 */

define(['jquery','backbone'], function ($, Backbone) {

	var Lazy = {

		View : Backbone.View.extend({
			properties : {},

			initialize : function () {

				this.$el = this.el = $(this.properties.el);

				if (this.lazyTemplate) {
					this.template = _.template(this.lazyTemplate.toString().split("/**")[1].split("**/")[0])
				} else {
					this.template = _.template(this.properties.template);
				}

				if(this.collection) {
					//this.listenTo(this.collection, "sync", this.render);
					this.listenTo(this.collection, "all", this.render);
				}
				if(this.model) {
					//this.listenTo(this.model, "sync", this.render);
					this.listenTo(this.model, "all", this.render)
				}
			},
			render : function () {
				var objDataToBeRendered = {};

				if(this.model) { objDataToBeRendered[this.properties.alias] = this.model.toJSON(); }
				if(this.collection) { objDataToBeRendered[this.properties.alias] = this.collection.toJSON(); }

				var renderedContent = this.template(objDataToBeRendered);
				this.el.html(renderedContent);
				this.trigger("rendered")
				return this;
			},
			close : function () {
				this.unbind(); // Unbind all local event bindings
				if(this.model) { this.model.unbind("change", this.render, this); }
				if(this.collection) { this.collection.unbind("sync", this.render, this); }
				this.remove(); // Remove view from DOM
				delete this.$el;
				delete this.el;
			},
			getData : function(selector, attribute) {
				return this.$el.find(selector).data(attribute);
			},
			setData : function(selector, attribute, data) {
				return this.$el.find(selector).data(attribute, data);
			},
			getDataValue : function(e) {
				return e.target.dataset.value;
			},
			getData : function(what, e) {
				return e.target.dataset[what];
			},
			getValue : function(selector) {
				return this.$el.find(selector).val();
			},
			getSelectedValue : function(e) {
				return e.target.value;
			},
			setValue : function(selector, value) {
				return this.$el.find(selector).val(value);
			},
			getText : function(selector) {
				return this.$el.find(selector).text();
			},
			setText : function(selector, text) {
				return this.$el.find(selector).text(text);
			},
			getHtml : function(selector) {
				return this.$el.find(selector).html();
			},
			setHtml : function(selector, html) {
				return this.$el.find(selector).html(html);
			},
			getHashValue : function(e) {
				return e.target.hash.split("#")[1];
			}
		}),

		Controller : Backbone.View.extend({}),

		Application : Backbone.Router.extend({

		})

	};

	return Lazy;
});


