import React from 'react';
import PropTypes from 'prop-types';
import { buildUrl } from '../util/buildUrl';
import SequenceLink from './SequenceLink';

const sequenceClasses = new Set(['protein', 'cds', 'transcript']);

const Link = (props) => {
  return (
    <>
      <a href={buildUrl(props)}>
        <span className={props.classes?.linkLabel}>{props.label}</span>
      </a>
      {sequenceClasses.has(props.class) ? <SequenceLink {...props} /> : null}
    </>
  );
};

Link.propTypes = {
  id: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  class: PropTypes.string.isRequired,
  classes: PropTypes.object,
};

export default Link;
