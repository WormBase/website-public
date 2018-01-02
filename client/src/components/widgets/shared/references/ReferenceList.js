import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default class ReferenceList extends Component {
  static propTypes = {
    data: PropTypes.array.isRequired,
    children: PropTypes.func.isRequired,
  };

  render() {
    const pageData = this.props.data;
    return (
      <div>
        {
          this.props.children(pageData)
        }
      </div>
    );
  }
}
