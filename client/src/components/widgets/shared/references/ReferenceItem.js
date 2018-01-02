import React, { Component } from 'react';
import PropTypes from 'prop-types';

export default class ReferenceItem extends Component {
  static propTypes = {
    data: PropTypes.shape({
      name: PropTypes.shape({
        id: PropTypes.string.isRequired
      }).isRequired,
    }),
  };

  render() {
    const {data} = this.props;
    return (
      <div>
        {
          JSON.stringify(data)
        }
      </div>
    );
  }
}
