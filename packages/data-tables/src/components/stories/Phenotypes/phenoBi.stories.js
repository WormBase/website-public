import React from 'react'
import { phenotype_widget } from '../../../../.storybook/target'
import Wrapper from '../../Wrapper'

const id = 'table_phenotype_by_interaction'
const order = ['phenotype', 'interactions', 'interaction_type', 'citations']
const columnsHeader = {
  interaction_type: 'Interaction Type',
  citations: 'Citations',
  phenotype: 'Phenotype',
  interactions: 'Interactions',
}

export default {
  component: Wrapper,
  title: 'Table/Generic/Widgets/Phenotypes/phenotypes_by_interaction',
}

export const daf8 = () => (
  <Wrapper
    WBid={phenotype_widget.WBid.daf8}
    tableType={phenotype_widget.tableType.phenotypeByInteraction}
    {...{ id, order, columnsHeader }}
  />
)
export const daf16 = () => (
  <Wrapper
    WBid={phenotype_widget.WBid.daf16}
    tableType={phenotype_widget.tableType.phenotypeByInteraction}
    {...{ id, order, columnsHeader }}
  />
)
export const mig2 = () => (
  <Wrapper
    WBid={phenotype_widget.WBid.mig2}
    tableType={phenotype_widget.tableType.phenotypeByInteraction}
    {...{ id, order, columnsHeader }}
  />
)
