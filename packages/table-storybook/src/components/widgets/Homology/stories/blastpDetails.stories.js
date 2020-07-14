import React from 'react'
import BlastpDetails from '../BlastpDetails'
import { homology_widget } from '../../../../../.storybook/target'

export default {
  component: BlastpDetails,
  title: 'Table|Widgets/Homology/blastp_details',
}

export const daf8 = () => (
  <BlastpDetails
    WBid={homology_widget.WBid.daf8}
    tableType={homology_widget.tableType.blastpDetails}
  />
)
