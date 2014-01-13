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
  'jsx!components/appUsersList',
  'jsx!components/messagesList',
  'showdown' // ==> globals
], function($, _, Backbone, React
    , WelcomeComponent
    , LoginComponent
    , SignUpComponent
    , MessageFormComponent
    , AppUsersList
    , MessagesList
   )

{
  //"use strict";

  var Application = function() {

    console.log("=== Start application ===")

    var messageTitle = "CuiCui With Golo and React";
    var loginMessage = "Please login: ";
    var signUpMessage = "New User? ";
    var labelMessage = "Type a title and a message: ";

    var appUsersUrl = "appusers";

    var messagesUrl = "last_message"


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

    React.renderComponent(
      <AppUsersList url={appUsersUrl} pollInterval={500}/>,
      document.querySelector('appusers-list')
    );


    React.renderComponent(
      <MessagesList url={messagesUrl} maxmessages={10} pollInterval={500}/>,
      document.querySelector('messages-list')
    );
  }

  return Application;
});
