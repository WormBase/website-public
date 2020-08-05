import React, { useState } from 'react'
import PropTypes from 'prop-types'
import Accordion from '@material-ui/core/Accordion'
import AccordionDetails from '@material-ui/core/AccordionDetails'
import AccordionSummary from '@material-ui/core/AccordionSummary'
import ExpandMoreIcon from '@material-ui/icons/ExpandMore'

const EvidenceCell = ({ renderContent, renderEvidence, data }) => {
  const [expanded, setExpanded] = useState(true)

  return (
    <Accordion expanded={expanded} onChange={() => setExpanded(!expanded)}>
      <AccordionSummary expandIcon={<ExpandMoreIcon />}>
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
  )
}

EvidenceCell.propTypes = {
  data: PropTypes.shape({
    text: PropTypes.any,
    evidence: PropTypes.object,
  }),
  renderContent: PropTypes.func,
  renderEvidence: PropTypes.func,
}

export default EvidenceCell
