/** @jsx React.DOM */

var AnimalForm = React.createClass({
  onClick: function() {
    var nickName = this.refs.nickName.getDOMNode().value.trim();
    if (!nickName) {
      return false;
    }

    // send request to the server
    this.postAnimal(JSON.stringify({nickName: nickName}));

    this.refs.nickName.getDOMNode().value = '';
    return false;
  },
  postAnimal: function(animal) {
    $.ajax({
      url: this.props.url,
      type: 'POST',
      data: animal,
      success: function(data) {
        //this.setState({data: data});
      }.bind(this)
    });
  },
  render: function() {
    return (
      <div className="animalForm">
        <input type="text" placeholder="NickName" ref="nickName"/>
        <button onClick={this.onClick}>Add</button>
      </div>

      );
  }
});

React.renderComponent(
  <AnimalForm url="animals"/>,
  document.querySelector('animal-form')
);
