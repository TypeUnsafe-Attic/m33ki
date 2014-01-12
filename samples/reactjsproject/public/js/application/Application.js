/**
 * @jsx React.DOM
 */
define([
  'jquery',
  'underscore',
  'backbone',
  'react',
  'jsx!components/welcome',
  'jsx!components/login',
  'jsx!components/signup',
  'jsx!components/messageForm',
  'showdown' // ==> globals
], function($, _, Backbone, React, WelcomeComponent, LoginComponent, SignUpComponent, MessageFormComponent)
{
  //"use strict";

  var Application = function() {

    var messageTitle = "CuiCui With Golo and React";
    var loginMessage = "Please login: ";

    var signUpMessage = "New User? ";

    var labelMessage = "Type a title and a message: ";



    React.renderComponent(
      <LoginComponent message={loginMessage} url="login"/>,
      document.querySelector('login')
    );

    React.renderComponent(
      <SignUpComponent message={signUpMessage} url="signup"/>,
      document.querySelector('signup')
    );

    React.renderComponent(
      <MessageFormComponent label={labelMessage} url="messages"/>,
      document.querySelector('message-form')
    );

    React.renderComponent(
      <WelcomeComponent message={messageTitle}/>,
      document.querySelector('welcome-title')
    );


  }

  return Application;
});
