import React from 'react';
import OntologyGraphBase from './OntologyGraphBase';

import Radio from '@material-ui/core/Radio';
import RadioGroup from '@material-ui/core/RadioGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import FormControl from '@material-ui/core/FormControl';
import FormLabel from '@material-ui/core/FormLabel';

export default function PhenotypeOntologyGraph({ focusTermId }) {
  return (
    <OntologyGraphBase
      useOntologyGraphParams={{
        datatype: 'Phenotype',
        focusTermId: focusTermId,
      }}
      renderCustomSidebar={({ state, dispatch }) => {
        return (
          <React.Fragment>
            <FormControl component="fieldset">
              <FormLabel component="legend">Evidence type</FormLabel>
              <RadioGroup
                aria-label="evidence-type"
                name="evidence-type"
                value={state.et}
                onChange={(event) =>
                  dispatch({
                    type: 'set_evidence_filter',
                    payload: event.target.value,
                  })
                }
                column
              >
                <FormControlLabel
                  value="all"
                  control={<Radio />}
                  label="Any evidence type"
                />
                <FormControlLabel
                  value="onlyrnai"
                  control={<Radio />}
                  label="RNAi only"
                />
                <FormControlLabel
                  value="onlyvariation"
                  control={<Radio />}
                  label="Variation only"
                />
              </RadioGroup>
            </FormControl>
          </React.Fragment>
        );
      }}
    />
  );
}

PhenotypeOntologyGraph.displayName = 'PhenotypeOntologyGraph';
