import React from 'react';
import PropTypes from 'prop-types';
import SimpleCell from './SimpleCell';
import Link from './Link';

const PatoEntityCell = ({ data }) => {
  const { entity_term, pato_term } = data || {};
  return (
    <SimpleCell>
      <Link {...entity_term} />
      {`, ${pato_term}`}
    </SimpleCell>
  );
};

PatoEntityCell.propTypes = {
  data: PropTypes.shape({
    entity_term: PropTypes.any,
    pato_term: PropTypes.string,
  }),
};
export default PatoEntityCell;
