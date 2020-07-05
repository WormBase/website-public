import React from 'react'
import Blastp from './Blastp'
import { homology_widget } from '../../../../.storybook/target'

export default {
  component: Blastp,
  title: 'Table|Widgets/Homology/best_blastp_matches',
}

export const daf16 = () => (
  <Blastp
    WBid={homology_widget.WBid.daf16}
    tableType={homology_widget.tableType.blastp}
  />
)
