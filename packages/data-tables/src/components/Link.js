import React from 'react';
import PropTypes from 'prop-types';
import { buildUrl } from '../util/buildUrl';

const resourcePages = new Set([
  'analysis',
  'author',
  'gene_class',
  'laboratory',
  'molecule',
  'motif',
  'paper',
  'person',
  'reagents',
  'disease',
  'transposon_family',
  'wbprocess',
]);

const Link = (props) => {
  return (
    <a href={buildUrl(props, resourcePages)}>
      <span className={props.classes?.linkLabel}>{props.label}</span>
    </a>
  );
};

Link.propTypes = {
  id: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
  class: PropTypes.string.isRequired,
  classes: PropTypes.object.isRequired,
};

export default Link;
