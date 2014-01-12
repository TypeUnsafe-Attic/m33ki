/** @jsx React.DOM */
define(["react"], function (React) {

  //TODO: avec BB

  var LoginComponent = React.createClass({

    render: function() {
      var successStyle = {
        color: 'green'
      };
      var errorStyle = {
        color: 'red'
      };

      return (
        <form className="userForm" onSubmit={this.handleSubmit}>
          {this.props.message}
          <input type="text" placeholder="Pseudo" ref="pseudo"/>
          <input type="password" placeholder="password" ref="password"/>
          <input type="submit" value="Login" />
          <button onClick={this.handleClick} ref="btnLogOut">Logout</button>
          <legend style={successStyle} ref="successLoginMessage"></legend>
          <legend style={errorStyle} ref="errorLoginMessage"></legend>
          <b>{this.state.message()}</b>
        </form>
        );
    },
    getInitialState: function() {

      return {
        pseudo: null,
        authenticated: false,
        message : function() {
          if(this.pseudo != null) return this.pseudo + " is connected";
        }
      };
    },
    componentDidMount: function() {

      // check if authenticated
      $.get("authenticated", function(data){
        console.log(data);

        this.setState({
          pseudo: data.pseudo,
          authenticated: data.authenticated
        });

        this.refs.btnLogOut.getDOMNode().disabled = !data.authenticated;

      }.bind(this))

    },
    handleSubmit : function() {
      //var that = this;
      var pseudo = this.refs.pseudo.getDOMNode().value.trim();
      var password = this.refs.password.getDOMNode().value.trim();
      if (!pseudo || !password) {
        return false;
      }

      // send request to the server
      $.ajax({
        type: "POST",
        url: this.props.url,
        data: JSON.stringify({pseudo: pseudo, password: password}),
        success: function(data){
          console.log("success", data);
          this.refs.successLoginMessage.getDOMNode().innerHTML = "Welcome " + pseudo;
          this.refs.errorLoginMessage.getDOMNode().innerHTML = "";
          this.refs.btnLogOut.getDOMNode().disabled = false;
        }.bind(this),
        error: function(err){
          console.log("error", err);
          this.refs.successLoginMessage.getDOMNode().innerHTML = "";
          this.refs.errorLoginMessage.getDOMNode().innerHTML = err.responseText + " " + err.statusText;
        }.bind(this),
        dataType: "json"
      });

      this.refs.pseudo.getDOMNode().value = '';
      this.refs.password.getDOMNode().value = '';

      return false;
      /*
       http://facebook.github.io/react/docs/tutorial.html

       We always return false from the event handler to prevent
       the browser's default action of submitting the form.
       (If you prefer, you can instead take the event as an argument
       and call preventDefault() on it.)
       */
    },
    handleClick : function() {
      $.get("logout", function(data){
        console.log(data);
        this.refs.successLoginMessage.getDOMNode().innerHTML = "";
        this.refs.errorLoginMessage.getDOMNode().innerHTML = "";
        this.setState({
          pseudo: null,
          authenticated: false
        });
        this.refs.btnLogOut.getDOMNode().disabled = true;

      }.bind(this))
    }
  });
  return LoginComponent;

});