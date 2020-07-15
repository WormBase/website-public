import React from 'react';
import '../../../../root/css/main.css';
import LegacyDataField from './LegacyDataField';

export default { title: 'Legacy' };

export const DataFieldDefault = () => (
  <div className="one-column">
    <LegacyDataField title={'Field name'}>
      Field Content, should be side by side with the field title on large screen.
    </LegacyDataField>
  </div>
);
