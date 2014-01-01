window.ModelsList = {

  getModels: function() {
    $.ajax({
      url: this.props.url,
      success: function(data) {
        this.setState({data: data});
      }.bind(this)
    });
  },
  getInitialState: function() {
    return {data: []};
  },
  componentWillMount: function() {
    this.getModels();
    setInterval(this.getModels, this.props.pollInterval);
  }

};