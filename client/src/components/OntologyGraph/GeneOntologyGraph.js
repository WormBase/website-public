import React from 'react';
import OntologyGraphBase from './OntologyGraphBase';
import useOntologyGraph from './useOntologyGraph';

import Radio from '@material-ui/core/Radio';
import RadioGroup from '@material-ui/core/RadioGroup';
import Checkbox from '@material-ui/core/Checkbox';
import FormGroup from '@material-ui/core/FormGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import FormControl from '@material-ui/core/FormControl';
import FormLabel from '@material-ui/core/FormLabel';

export default function GeneOntologyGraph({ focusTermId }) {
  return (
    <OntologyGraphBase
      useOntologyGraphParams={{
        datatype: 'Go',
        focusTermId: focusTermId,
      }}
      renderCustomSidebar={({ state, dispatch }) => {
        const renderGOAspectCheckbox = ({ value, label }) => {
          return (
            <FormControlLabel
              control={
                <Checkbox
                  checked={state.rootsChosen.has(value)}
                  value={value}
                  onChange={(event) => {
                    dispatch({
                      type: `${
                        event.target.checked ? 'add' : 'remove'
                      }_go_root`,
                      payload: event.target.value,
                    });
                  }}
                />
              }
              label={label}
            />
          );
        };

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
                  value="withiea"
                  control={<Radio />}
                  label="Any evidence type"
                />
                <FormControlLabel
                  value="excludeiea"
                  control={<Radio />}
                  label="Exclude IEA"
                />
                <FormControlLabel
                  value="onlyiea"
                  control={<Radio />}
                  label="Experimental evidence only"
                />
              </RadioGroup>
            </FormControl>
            <FormControl component="fieldset">
              <FormLabel component="legend">Aspects</FormLabel>
              <FormGroup>
                {renderGOAspectCheckbox({
                  value: 'GO:0008150',
                  label: 'Biological Process',
                })}
                {renderGOAspectCheckbox({
                  value: 'GO:0005575',
                  label: 'Cellular Component',
                })}
                {renderGOAspectCheckbox({
                  value: 'GO:0003674',
                  label: 'Molecular Function',
                })}
              </FormGroup>
            </FormControl>
          </React.Fragment>
        );
      }}
    />
  );
}
