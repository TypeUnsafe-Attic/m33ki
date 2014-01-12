/** @jsx React.DOM */
define(["react"], function (React) {
  /*
    === Component Specs and Lifecycle ===
    http://facebook.github.io/react/docs/component-specs.html

  */
  var SignUpComponent = React.createClass({

    render: function() {

      return (
        <form className="signupForm" onSubmit={this.handleSubmit}>
          {this.props.message}
          <input type="text" placeholder="Email" ref="email"/>
          <input type="text" placeholder="Pseudo" ref="pseudo"/>
          <input type="password" placeholder="password" ref="password"/>
          <input type="submit" value="SignUp" />
          <b>{this.state.message}</b>
        </form>
        );
    },
    getInitialState: function() {
      return {
        message : "..."
      };
    },
    componentDidMount: function() { /* initialize when component rendered */

    },
    handleSubmit : function() {
      //var that = this;
      var pseudo = this.refs.pseudo.getDOMNode().value.trim();
      var password = this.refs.password.getDOMNode().value.trim();
      var email = this.refs.email.getDOMNode().value.trim();

      if (!pseudo || !password || !email) {
        return false;
      }

      this.setState({
        message : "Please wait ..."
      });

      // send request to the server
      $.ajax({
        type: "POST",
        url: this.props.url,
        data: JSON.stringify({pseudo: pseudo, password: password, email: email}),
        success: function(data){
          console.log("success", data);

          this.setState({
            message : data.message
          });


        }.bind(this),
        error: function(err){
          console.log("error", err);

          this.setState({
            message : err.responseText + " " + err.statusText
          });

        }.bind(this),
        dataType: "json"
      });

      this.refs.pseudo.getDOMNode().value = '';
      this.refs.password.getDOMNode().value = '';
      this.refs.email.getDOMNode().value = '';

      return false;
      /*
       http://facebook.github.io/react/docs/tutorial.html

       We always return false from the event handler to prevent
       the browser's default action of submitting the form.
       (If you prefer, you can instead take the event as an argument
       and call preventDefault() on it.)
       */
    }

  });
  return SignUpComponent;

});