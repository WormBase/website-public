import React from 'react';
import PropTypes from 'prop-types';
import Link from './Link';

const SimpleCell = ({ data }) => {
  if (data !== null && typeof data === 'object') {
    if (data.text && typeof data.text !== 'object') {
      return <span>{data.text}</span>;
    } else if (data.class) {
      return <Link {...data} />;
    } else {
      return (
        <span style={{ wordBreak: 'break-all' }}>{JSON.stringify(data)}</span>
      );
    }
  } else {
    return <span>{data}</span>;
  }
};

SimpleCell.propTypes = {
  data: PropTypes.any,
};

export default SimpleCell;
