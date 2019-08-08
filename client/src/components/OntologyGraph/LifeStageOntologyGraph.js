import React from 'react';
import OntologyGraphBase from './OntologyGraphBase';

export default function LifeStageOntologyGraph({ focusTermId }) {
  return (
    <OntologyGraphBase
      useOntologyGraphParams={{
        datatype: 'Lifestage',
        focusTermId: focusTermId,
      }}
    />
  );
}
