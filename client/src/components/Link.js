import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';

function buildUrl(tag, fuzzy) {
  const {id, label} = tag;
  if ((id && tag.class) || fuzzy) {
    return `/get?class=${tag.class}&name=${id || label}`;
  }
}

class Link extends Component {
  static propTypes = {
    id: PropTypes.string.isRequired,
    label: PropTypes.string.isRequired,
    "class": PropTypes.string.isRequired,
    classes: PropTypes.object.isRequired,
  };

  render() {
    return (
      <a href={buildUrl(this.props)}>
        <span className={this.props.classes.linkLabel}>{this.props.label}</span>
      </a>
    );
  }
}

const styles = {
  linkLabel: {},
};

export default withStyles(styles)(Link);

export {
  buildUrl,
};
