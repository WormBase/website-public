import React from 'react';
import OntologyGraphBase from './OntologyGraphBase';
import useOntologyGraph from './useOntologyGraph';

import Radio from '@material-ui/core/Radio';
import RadioGroup from '@material-ui/core/RadioGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import FormControl from '@material-ui/core/FormControl';
import FormLabel from '@material-ui/core/FormLabel';

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
