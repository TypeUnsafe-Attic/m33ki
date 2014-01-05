/**
 * @jsx React.DOM
 */
define([
  'jquery',
  'underscore',
  'backbone',
  'react',
  'jsx!components/welcome',
  'showdown' // ==> globals
], function($, _, Backbone, React, WelcomeComponent)
{
  //"use strict";

  var Application = function() {

    var message1 = "=== Hello World! ==="

    React.renderComponent(
      <WelcomeComponent message={message1}/>,
      document.querySelector('welcome-title')
    );
    React.renderComponent(
      <WelcomeComponent message="With Golo and React"/>,
      document.querySelector('welcome-title-bis')
    );

  }

  return Application;
});
