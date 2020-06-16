import React from 'react'
import Pheno from './Phenotype'
import PhenoBI from './PhenotypeByInteraction'

const target = {
  WBid: {
    daf8: 'WBGene00000904',
    daf16: 'WBGene00000912',
    mig2: 'WBGene00003239',
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
  title: 'Table|Widgets/Phenotypes/Gene page',
}

export const Phenotype_daf8 = () => (
  <Pheno WBid={target.WBid.daf8} tableType={target.tableType.pheno} />
)
export const Phenotype_daf16 = () => (
  <Pheno WBid={target.WBid.daf16} tableType={target.tableType.pheno} />
)
export const Phenotype_mig2 = () => (
  <Pheno WBid={target.WBid.mig2} tableType={target.tableType.pheno} />
)

export const PhenotypeNotObserved_daf8 = () => (
  <Pheno WBid={target.WBid.daf8} tableType={target.tableType.phenoNO} />
)
export const PhenotypeNotObserved_daf16 = () => (
  <Pheno WBid={target.WBid.daf16} tableType={target.tableType.phenoNO} />
)
export const PhenotypeNotObserved_mig2 = () => (
  <Pheno WBid={target.WBid.mig2} tableType={target.tableType.phenoNO} />
)

export const DrivesOverexpression_daf8 = () => (
  <Pheno WBid={target.WBid.daf8} tableType={target.tableType.drivesOE} />
)
export const DrivesOverexpression_daf16 = () => (
  <Pheno WBid={target.WBid.daf16} tableType={target.tableType.drivesOE} />
)
export const DrivesOverexpression_mig2 = () => (
  <Pheno WBid={target.WBid.mig2} tableType={target.tableType.drivesOE} />
)

export const PhenotypeByInteraction_daf8 = () => (
  <PhenoBI WBid={target.WBid.daf8} tableType={target.tableType.phenoBI} />
)
export const PhenotypeByInteraction_daf16 = () => (
  <PhenoBI WBid={target.WBid.daf16} tableType={target.tableType.phenoBI} />
)
export const PhenotypeByInteraction_mig2 = () => (
  <PhenoBI WBid={target.WBid.mig2} tableType={target.tableType.phenoBI} />
)
