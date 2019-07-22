import React from 'react';
import OntologyGraphBase from './OntologyGraphBase';
import useOntologyGraph from './useOntologyGraph';

import Radio from '@material-ui/core/Radio';
import RadioGroup from '@material-ui/core/RadioGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import FormControl from '@material-ui/core/FormControl';
import FormLabel from '@material-ui/core/FormLabel';

export default function AnatomyOntologyGraph({ focusTermId }) {
  return (
    <OntologyGraphBase
      useOntologyGraphParams={{
        datatype: 'Anatomy',
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
                  value="onlyexprcluster"
                  control={<Radio />}
                  label="Expression cluster only"
                />
                <FormControlLabel
                  value="onlyexprpattern"
                  control={<Radio />}
                  label="Expression pattern only"
                />
              </RadioGroup>
            </FormControl>
          </React.Fragment>
        );
      }}
    />
  );
}
