/** @jsx React.DOM */

var AnimalsList = React.createClass({
  getInitialState: function() {
    return {data: []};
  },
  loadAnimalsFromServer : function() {
    $.ajax({
      url: this.props.url,
      success: function(data) {
        this.setState({data: data});
      }.bind(this)
    });
  },
  componentWillMount: function() {
    this.loadAnimalsFromServer();
    setInterval(this.loadAnimalsFromServer, this.props.pollInterval);
  },
  render: function() {
    var animalsNodes = this.state.data.map(function(animal){
      return <li>{animal.id} - {animal.nickName}</li>;
    });
    return (
      <ul className="myList">
        {animalsNodes}
      </ul>
    );
  }
});

React.renderComponent(
  <AnimalsList url="animals" pollInterval={1000}/>,
  document.querySelector('animals-list')
);
