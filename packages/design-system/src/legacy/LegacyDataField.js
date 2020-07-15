import React from 'react';
import PropTypes from 'prop-types';

const LegacyDataField = ({title, children}) => (
  <div className="field">
    <div className="field-title">
      {title}
    </div>
    <div className="field-content">
      {children}
    </div>
  </div>
);

LegacyDataField.PropTypes = {
  title: PropTypes.any,
  children: PropTypes.any,
};

export default LegacyDataField;
