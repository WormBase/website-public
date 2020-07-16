import React from 'react';
import PropTypes from 'prop-types';

const LegacyLinkExternal = ({href, children}) => (
  <a href={href} target="_blank">
    <span class="wb-ext">
      {children}
    </span>
  </a>
);

LegacyLinkExternal.propTypes = {
  href: PropTypes.string,
  children: PropTypes.any,
};

export default LegacyLinkExternal;
