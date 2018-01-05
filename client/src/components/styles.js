import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withTheme } from 'material-ui/styles';

const fitComponent = (WrappedComponent) => {

  class FittedComponent extends Component {

    static propTypes = {
      children: PropTypes.element.isRequired,
      widthOnly: PropTypes.bool,
      heightOnly: PropTypes.bool,
    };

    render() {
      const {theme, heightOnly, widthOnly, ...childProps} = this.props;
      const defaultMargin = -2 * theme.spacing.unit;
      const style = {
        width: `calc(100% + ${-2 * defaultMargin}px)`,
        margin: `${0}px ${heightOnly ? 0 : defaultMargin}px`,
      };
      return (<WrappedComponent style={style} {...childProps} />);
    }
  }

  return withTheme()(FittedComponent);
}

export {
  fitComponent
};
