import React, { useState } from 'react';
import PropTypes from 'prop-types';
import Accordion from '@material-ui/core/Accordion';
import AccordionDetails from '@material-ui/core/AccordionDetails';
import AccordionSummary from '@material-ui/core/AccordionSummary';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
  root: {
    backgroundColor: 'transparent',
    boxShadow: 'none',
  },
  accordionSummaryRoot: {
    minHeight: 0,
    paddingLeft: 0,

    '&.Mui-expanded': {
      minHeight: 0,
    },
  },
  accordionSummaryContent: {
    margin: 0,

    '&.Mui-expanded': {
      margin: 0,
    },
  },
  accordionSummaryExpandIcon: {
    padding: 0,
  },
}));

const EvidenceCell = ({
  renderContent,
  renderEvidence,
  data,
  defaultExpanded = false,
}) => {
  const [expanded, setExpanded] = useState(defaultExpanded);
  const classes = useStyles();

  return (
    <Accordion
      classes={{
        root: classes.root,
      }}
      expanded={expanded}
      onChange={() => setExpanded(!expanded)}
    >
      <AccordionSummary
        classes={{
          root: classes.accordionSummaryRoot,
          content: classes.accordionSummaryContent,
          expanded: classes.accordionSummaryExpanded,
          expandIcon: classes.accordionSummaryExpandIcon,
        }}
        expandIcon={<ExpandMoreIcon fontSize="small" />}
      >
        <div>
          {renderContent({
            contentData: data.text,
            data: data,
          })}
        </div>
      </AccordionSummary>
      <AccordionDetails>
        <span>
          {renderEvidence({
            evidenceData: data.evidence,
            data: data,
          })}
        </span>
      </AccordionDetails>
    </Accordion>
  );
};

EvidenceCell.propTypes = {
  data: PropTypes.shape({
    text: PropTypes.any,
    evidence: PropTypes.object,
  }),
  renderContent: PropTypes.func,
  renderEvidence: PropTypes.func,
};

export default EvidenceCell;
