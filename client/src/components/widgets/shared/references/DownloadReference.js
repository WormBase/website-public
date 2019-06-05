import React, { Component } from 'react';
import PropTypes from 'prop-types';
import DownloadButton from '../../../DownloadButton';

class DownloadReference extends Component {
  contentFunc = () => {
    return import('json2csv').then((module) => {
      const json2csvParser = new module.Parser({
        fields: [
          {
            label: 'WormBase paper Id',
            value: 'name.id',
          },
          {
            label: 'Year',
            value: 'year',
          },
          {
            label: 'Type',
            value: 'ptype',
          },
          {
            label: 'Citation',
            value: 'name.label',
          },
          {
            label: 'Title',
            value: 'title.0',
          },
          {
            label: 'Journal',
            value: 'journal.0',
          },
          {
            label: 'Abstract',
            value: 'abstract.0',
          },
        ],
      });
      return json2csvParser.parse(this.props.data);
    });
  };

  render() {
    const { data, ...others } = this.props;
    return <DownloadButton {...others} contentFunc={this.contentFunc} />;
  }
}

DownloadReference.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      name: PropTypes.shape({
        id: PropTypes.string,
        label: PropTypes.string,
      }).isRequired,
      journal: PropTypes.any,
      abstract: PropTypes.any,
      title: PropTypes.any,
      ptype: PropTypes.string,
      year: PropTypes.string,
    })
  ).isRequired,
};

export default DownloadReference;
