import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from 'material-ui/styles';

class Fit extends Component {
  static propTypes = {
    children: PropTypes.element.isRequired,
    widthOnly: PropTypes.bool,
    heightOnly: PropTypes.bool,
    classes: PropTypes.object.isRequired,
  };
  render() {
    return (
      <div className={this.props.classes.root}>
        {this.props.children}
      </div>
    );
  }
}

const styles = (theme) => ({
  root: {
    width: `calc(100% + ${4 * theme.spacing.unit}px)`,
    margin: `0 ${-2 * theme.spacing.unit}px`,
  },
});

export default withStyles(styles)(Fit);
