/** @jsx React.DOM */
define(["react"], function (React) {

  var MessageFormComponent = React.createClass({

    render: function() {

      return (
        <form className="messageForm" onSubmit={this.handleSubmit}>
          {this.props.label}
          <input type="text" placeholder="title" ref="title"/><br></br>
          <textarea rows="10" cols="50" ref="message">Write something here</textarea><br></br>
          <input type="submit" value="Post message" />
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
      var title = this.refs.title.getDOMNode().value.trim();
      var message = this.refs.message.getDOMNode().value.trim();

      if (!title || !message) {
        return false;
      }

      this.setState({
        message : "Please wait ..."
      });

      // send request to the server
      $.ajax({
        type: "POST",
        url: this.props.url,
        data: JSON.stringify({title: title, message: message}),
        success: function(data){
          console.log("success", data);

          this.setState({
            message : "Posted! " + data.message
          });

        }.bind(this),
        error: function(err){
          console.log("error", err);

          this.setState({
            message  : err.responseText + " " + err.statusText
          });

        }.bind(this),
        dataType: "json"
      });

      this.refs.title.getDOMNode().value = '';
      this.refs.message.getDOMNode().value = '';

      return false;
    }

  });
  return MessageFormComponent;

});