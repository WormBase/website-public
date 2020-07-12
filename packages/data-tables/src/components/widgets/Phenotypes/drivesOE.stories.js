import React from 'react'
import Pheno from './Phenotype'
import { phenotype_widget } from '../../../../.storybook/target'

export default {
  component: Pheno,
  title: 'Table|Widgets/Phenotypes/drives_overexpression',
}

export const daf8 = () => (
  <Pheno
    WBid={phenotype_widget.WBid.daf8}
    tableType={phenotype_widget.tableType.drivesOverexpressionFlat}
  />
)
export const daf16 = () => (
  <Pheno
    WBid={phenotype_widget.WBid.daf16}
    tableType={phenotype_widget.tableType.drivesOverexpressionFlat}
  />
)
export const mig2 = () => (
  <Pheno
    WBid={phenotype_widget.WBid.mig2}
    tableType={phenotype_widget.tableType.drivesOverexpressionFlat}
  />
)
