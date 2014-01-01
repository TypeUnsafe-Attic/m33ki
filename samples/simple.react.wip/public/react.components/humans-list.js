/** @jsx React.DOM */

var HumansList = React.createClass({
  mixins: [window.ModelsList],
  /*
  getInitialState: function() {
    return {data: []};
  },
  loadHumansFromServer : function() {
    $.ajax({
      url: this.props.url,
      success: function(data) {
        this.setState({data: data});
      }.bind(this)
    });
  },
  componentWillMount: function() {
    this.loadHumansFromServer();
    setInterval(this.loadHumansFromServer, this.props.pollInterval);
  },
  */
  render: function() {
    var humansNodes = this.state.data.map(function(human){
      return <li>{human.id} - {human.firstName} - {human.lastName} </li>;
    });
    return (
      <ul className="myList">
        {humansNodes}
      </ul>
    );
  }
});

React.renderComponent(
  <HumansList url="humans" pollInterval={1000}/>,
  document.querySelector('humans-list')
);
