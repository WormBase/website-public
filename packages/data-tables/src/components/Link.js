import React from 'react';
import PropTypes from 'prop-types';
import { buildUrl } from '../util/buildUrl';

const Link = (props) => {
  return (
    <a href={buildUrl(props)}>
      <span className={props.classes?.linkLabel}>{props.label}</span>
    </a>
  );
};

Link.propTypes = {
  id: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  class: PropTypes.string.isRequired,
  classes: PropTypes.object,
};

export default Link;
