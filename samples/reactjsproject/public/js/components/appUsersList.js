/** @jsx React.DOM */
define(["react", "jquery"], function (React, $) {

  var AppUsersList = React.createClass({

    getInitialState: function() {
      return {data: []};
    },

    getModels: function() {
      $.ajax({
        url: this.props.url,
        success: function(data) {
          this.setState({data: data});
        }.bind(this)
      });
    },

    componentWillMount: function() {
      this.getModels();
      setInterval(this.getModels, this.props.pollInterval);
    },

    render: function() {
      var appUsersNodes = this.state.data.map(function(user){
        return <li>{user.id} - {user.pseudo} - {user.email} </li>;
      });
      return (
        <ul className="myList">
        {appUsersNodes}
        </ul>
      );
    }
  });
  return AppUsersList;

});

