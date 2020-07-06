import React from 'react'
import PhenoBI from './PhenotypeByInteraction'
import { phenotype_widget } from '../../../../.storybook/target'

export default {
  component: PhenoBI,
  title: 'Table|Widgets/Phenotypes/phenotype_by_interaction',
}

export const daf8 = () => (
  <PhenoBI
    WBid={phenotype_widget.WBid.daf8}
    tableType={phenotype_widget.tableType.phenoByInteraction}
  />
)
export const daf16 = () => (
  <PhenoBI
    WBid={phenotype_widget.WBid.daf16}
    tableType={phenotype_widget.tableType.phenoByInteraction}
  />
)
export const mig2 = () => (
  <PhenoBI
    WBid={phenotype_widget.WBid.mig2}
    tableType={phenotype_widget.tableType.phenoByInteraction}
  />
)
