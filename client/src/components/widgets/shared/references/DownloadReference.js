import React, { Component } from 'react';
import PropTypes from 'prop-types';
import DownloadButton from '../../../DownloadButton';

class DownloadReference extends Component {
  contentFunc = () => {
    import('json2csv').then((module) => {
      return JSON.stringify(this.props.data);
    });
  }

  render() {
    const {data, ...others} = this.props;
    return (
      <DownloadButton {...others} contentFunc={this.contentFunc} />
    );
  }
}

DownloadReference.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.shape({
        id: PropTypes.string.isRequired,
        "class": PropTypes.string.isRequired,
      }).isRequired,
      author: PropTypes.array,
    })
  ).isRequired,
};

export default DownloadReference;