/** @jsx React.DOM */
define(["react"], function (React) {

  var WelcomeComponent = React.createClass({

    render: function() {
      return (
        <h1>Welcome {this.props.message}</h1>
        );
    }
  });
  return WelcomeComponent;

});

