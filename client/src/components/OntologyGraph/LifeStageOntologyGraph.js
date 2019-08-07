import React from 'react';
import OntologyGraphBase from './OntologyGraphBase';

export default function LifeStageOntologyGraph({ focusTermId }) {
  return (
    <OntologyGraphBase
      useOntologyGraphParams={{
        datatype: 'LifeStage',
        focusTermId: focusTermId,
      }}
    />
  );
}
