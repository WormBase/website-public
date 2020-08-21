import React from 'react';
import PropTypes from 'prop-types';
import EvidenceCell from './EvidenceCell';
import SimpleCell from './SimpleCell';
import ListCell from './ListCell';
import HashCell from './HashCell';
import PatoEntityCell from './PatoEntityCell';

function SmartCell({ data }) {
  if (data !== null && typeof data === 'object') {
    if (Array.isArray(data)) {
      return (
        <ListCell
          data={data}
          render={({ elementData }) => <SmartCell data={elementData} />}
        />
      );
    } else {
      if (data.evidence && data.text) {
        return (
          <EvidenceCell
            data={data}
            renderContent={({ contentData }) => (
              <SmartCell data={contentData} />
            )}
            renderEvidence={({ evidenceData }) => (
              <SmartCell data={evidenceData} />
            )}
          />
        );
      } else if (data.pato_evidence) {
        return <PatoEntityCell data={data.pato_evidence} />;
      } else if (data.class || data.text) {
        return <SimpleCell data={data} />;
      } else {
        return (
          <HashCell
            data={data}
            render={({ elementValue }) => <SmartCell data={elementValue} />}
          />
        );
      }
    }
  } else {
    return <SimpleCell data={data} />;
  }
}

SmartCell.propTypes = {
  data: PropTypes.any,
};

export default SmartCell;
