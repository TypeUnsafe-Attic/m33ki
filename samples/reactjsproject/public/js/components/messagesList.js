/** @jsx React.DOM */
define(["react", "jquery"], function (React, $) {

  var MessagesList = React.createClass({

    getInitialState: function() {
      return {data : [] , lastMessage : null, id : "", count : 0};
    },

    getLastMessage: function() {
      $.ajax({
        url: this.props.url,
        success: function(message) {

          console.log(message[0]);

          this.setState({lastMessage: message[0]});

          if(message[0].id != this.state.id) {
            this.state.data.push(message[0])
            this.setState({id: message[0].id})
          }

          this.setState({count: this.state.data.length})

          if(this.state.data.length > this.props.maxmessages) {
            //console.log("=== LIMIT ===", this.state.data)
            this.state.data.shift()
          }

        }.bind(this)
      });
    },

    componentWillMount: function() {

      this.getLastMessage();
      setInterval(this.getLastMessage, this.props.pollInterval);

    },

    render: function() {


      var messagesNodes = this.state.data.map(function(message){
        return <li>
            {message.id} ({message.publication}) 
            <br></br> 
            From {message.fromPseudo} : {message.title}
            <br></br> {message.message} 
          </li>;
      }).reverse();

      var nbMessages = this.state.count;

      return (
        <div>
          <b>{nbMessages} messages</b>
          <ol  className="myList">
            {messagesNodes}
          </ol>
        </div>
      );
    }
  });
  return MessagesList;

});

