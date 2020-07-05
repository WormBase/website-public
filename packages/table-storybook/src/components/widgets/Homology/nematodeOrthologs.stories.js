import React from 'react'
import NematodeOrthologs from './NematodeOrthologs'
import { homology_widget } from '../../../../.storybook/target'

export default {
  component: NematodeOrthologs,
  title: 'Table|Widgets/Homology/nematode_orthologs',
}

export const daf16 = () => (
  <NematodeOrthologs
    WBid={homology_widget.WBid.daf16}
    tableType={homology_widget.tableType.nemOrtho}
  />
)
