import React, { useState, useContext, useEffect, useMemo } from 'react';
import PropTypes from 'prop-types';
import Accordion from '@material-ui/core/Accordion';
import AccordionDetails from '@material-ui/core/AccordionDetails';
import AccordionSummary from '@material-ui/core/AccordionSummary';
import ArrowDropDownIcon from '@material-ui/icons/ArrowDropDown';
import ArrowRightIcon from '@material-ui/icons/ArrowRight';
import { makeStyles } from '@material-ui/core/styles';
import { hasContent } from '../util/hasContent';
import TableCellExpandAllContext from './TableCellExpandAllContext';

const useStyles = makeStyles((theme) => ({
  root: {
    backgroundColor: 'transparent',
    boxShadow: 'none',
    width: '100%',
  },
  accordionSummaryRoot: {
    minHeight: 0,
    paddingLeft: 0,

    '&.Mui-expanded': {
      minHeight: 0,
    },

    '&:hover': {
      backgroundColor: theme.palette.action.hover,
    },
  },
  accordionSummaryContent: {
    margin: 0,
    alignItems: 'center',

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
  defaultExpanded,
}) => {
  const expandedFromContext = useContext(TableCellExpandAllContext);
  const [expanded, setExpanded] = useState(false);

  useEffect(() => {
    setExpanded(expandedFromContext);
  }, [expandedFromContext, setExpanded]);

  useEffect(() => {
    // override expandedFromContext is this set or changes
    if (defaultExpanded) {
      setExpanded(defaultExpanded);
    }
  }, [defaultExpanded, setExpanded]);

  // console.log(`expandedFromContext: ${expandedFromContext}`);
  // console.log(`expanded: ${expanded}`);
  const classes = useStyles();

  const transitionProps = useMemo(
    () => ({
      timeout: 0,
    }),
    []
  );

  return Object.keys(data.evidence).filter((key) =>
    hasContent(data.evidence[key])
  ).length ? (
    <Accordion
      classes={{
        root: classes.root,
      }}
      TransitionProps={transitionProps}
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
      >
        {expanded ? (
          <ArrowDropDownIcon fontSize="small" />
        ) : (
          <ArrowRightIcon fontSize="small" />
        )}
        {renderContent({
          contentData: data.text,
          data: data,
        })}
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
  ) : (
    renderContent({
      contentData: data.text,
      data: data,
    })
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
