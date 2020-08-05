import React from 'react'
import { homology_widget } from '../../../../.storybook/target'
import Wrapper from '../../Wrapper'

const order = ['species', 'ortholog', 'method']
const id = 'table_nematode_orthologs'
const columnsHeader = {
  species: 'Species',
  ortholog: 'Ortholog',
  method: 'Method',
}

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Homology/nematode_orthologs',
}

export const daf8 = () => (
  <Wrapper
    WBid={homology_widget.WBid.daf8}
    tableType={homology_widget.tableType.nematodeOrthologs}
    {...{ id, order, columnsHeader }}
  />
)
export const daf16 = () => (
  <Wrapper
    WBid={homology_widget.WBid.daf16}
    tableType={homology_widget.tableType.nematodeOrthologs}
    {...{ id, order, columnsHeader }}
  />
)
export const mig2 = () => (
  <Wrapper
    WBid={homology_widget.WBid.mig2}
    tableType={homology_widget.tableType.nematodeOrthologs}
    {...{ id, order, columnsHeader }}
  />
)
