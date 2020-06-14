import React from 'react'
import Pheno from './Phenotype'
import PhenoBI from './PhenotypeByInteraction'
import PhenoNO from './PhenotypeNotObserved'
import DrivesOE from './DrivesOverexpression'

const target = {
  WBid: {
    daf8: 'WBGene00000904',
    daf16: 'WBGene00000912',
  },
  tableType: {
    pheno: 'phenotype',
    phenoNO: 'phenotype_not_observed',
    phenoBI: 'phenotype_by_interaction',
    drivesOE: 'drives_overexpression',
  },
}

export default {
  component: Pheno,
  PhenoBI,
  PhenoNO,
  DrivesOE,
  title: 'Table|Widgets/Phenotypes/Gene page',
}

export const Phenotype_daf8 = () => (
  <Pheno WBid={target.WBid.daf8} tableType={target.tableType.pheno} />
)
export const Phenotype_daf16 = () => (
  <Pheno WBid={target.WBid.daf16} tableType={target.tableType.pheno} />
)

export const PhenotypeByInteraction = () => <PhenoBI />
export const PhenotypeNotObserved = () => <PhenoNO />
export const DrivesOverexpression = () => <DrivesOE />
