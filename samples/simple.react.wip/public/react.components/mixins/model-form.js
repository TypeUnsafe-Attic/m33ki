
window.ModelForm = {

  postModel: function(model) {
    $.ajax({
      url: this.props.url,
      type: 'POST',
      data: model,
      success: function(data) {
        //this.setState({data: data});
      }.bind(this)
    });
  }
};


