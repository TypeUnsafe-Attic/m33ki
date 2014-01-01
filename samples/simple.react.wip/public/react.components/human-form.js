/** @jsx React.DOM */

var HumanForm = React.createClass({
  onClick: function() {
    var firstName = this.refs.firstName.getDOMNode().value.trim();
    var lastName = this.refs.lastName.getDOMNode().value.trim();
    if (!firstName || !lastName) {
      return false;
    }
    // send request to the server
    this.postHuman(JSON.stringify({firstName: firstName, lastName: lastName}));

    this.refs.firstName.getDOMNode().value = '';
    this.refs.lastName.getDOMNode().value = '';
    return false;
  },
  postHuman: function(human) {
    $.ajax({
      url: this.props.url,
      type: 'POST',
      data: human,
      success: function(data) {
        //this.setState({data: data});
      }.bind(this)
    });
  },
  render: function() {
    return (
      <div className="humanForm">
        <input type="text" placeholder="FirstName" ref="firstName"/>
        <input type="text" placeholder="LastName" ref="lastName"/>
        <button onClick={this.onClick}>Add</button>
      </div>

      );
  }
});

React.renderComponent(
  <HumanForm url="humans"/>,
  document.querySelector('human-form')
);
