import React from 'react';
import PropTypes from 'prop-types';

class SingleWidgetPage extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      html: null,
    };
  }

  componentDidMount() {
    fetch(this.props.widgetUrl).then((response) => {
      return response.text();
    }).then((widgetHtmlRaw) => {
      const re = /<script.*?>((.|\n|\r)+?)<\/script>/gi;
      const scripts = [];
      const widgetHtml = widgetHtmlRaw || `<script> console.log('zzzz'); </script>`;
      var match = re.exec(widgetHtml);
      //console.log(widgetHtml);
      while (match) {
        console.log(match);
        scripts.push(match[1]);
        match = re.exec(widgetHtml);
      }
      //console.log(scripts);

      this.setState({
        html: widgetHtml,
      }, () => {
        scripts.forEach((script) => {
          console.log(script);
          window.eval(script);
        });
      });
    });
  }

  render() {
    return (
      <div dangerouslySetInnerHTML={{__html: this.state.html}} />
    );
  }
}

SingleWidgetPage.propTypes = {
  widgetUrl: PropTypes.string.isRequired,
};

export default SingleWidgetPage;