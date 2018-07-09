import PropTypes from 'prop-types';

export const tagType = PropTypes.shape({
  id: PropTypes.string.isRequired,
  class: PropTypes.string.isRequired,
  label: PropTypes.string.isRequired,
});
