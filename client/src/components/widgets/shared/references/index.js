import React, { Component } from 'react';
import PropTypes from 'prop-types';
import ReferenceList from './ReferenceList';
import ReferenceItem from './ReferenceItem';

export default class References extends Component {
  static propTypes = {
    data: PropTypes.array.isRequired,
  };

  render() {
    return (
      <ReferenceList data={this.props.data}>
        {
          (pageData) => pageData.map(
            (itemData) => <ReferenceItem key={itemData.name.id} data={itemData} />
          )
        }
      </ReferenceList>
    );
  }
}
