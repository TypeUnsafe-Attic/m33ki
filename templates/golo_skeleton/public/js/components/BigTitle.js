/** @jsx React.DOM */
define(["react"], function (React) {

  var BigTitleComponent = React.createClass({

    styles : {
      h1: {
        class:"remove-bottom",
        style:{
          "margin-top": "40px"
        }
      }
    },

    render: function() {
      return (
        <div>
          <h1 className={this.styles.h1.class} style={this.styles.h1.style}>
            {this.props.message}
          </h1>
          <h5>{this.props.version}</h5>
          <hr></hr>
        </div>
      );
    }
  });
  return BigTitleComponent;

});
