import React from 'react';
import PropTypes from 'prop-types';
import withInnerHtmlFromUrl from './withInnerHtmlFromUrl';

class SingleWidgetPage extends React.Component {
  render() {
    const Widget = withInnerHtmlFromUrl('div', this.props.widgetUrl);
    return (
      <Widget id={`${this.props.widgetConf.name}-content`} className="content" style={{position: "relative", paddingTop: '2em',}} />
    );
  }
}

SingleWidgetPage.propTypes = {
  widgetUrl: PropTypes.string.isRequired,
  classConf: PropTypes.shape({
    title: PropTypes.string.isRequired,
  }),
  widgetConf: PropTypes.shape({
    title: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
  }),
  object: PropTypes.any,
};

export default SingleWidgetPage;