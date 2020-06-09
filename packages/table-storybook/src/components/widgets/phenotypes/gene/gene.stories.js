import React from 'react'
import Pheno from './Phenotype'
import PhenoBI from './PhenotypeByInteraction'
import PhenoNO from './PhenotypeNotObserved'
import DrivesOE from './DrivesOverexpression'

const targetUrl = {
  daf8: 'http://rest.wormbase.org/rest/field/gene/WBGene00000904/phenotype',
  daf16: 'http://rest.wormbase.org/rest/field/gene/WBGene00000912/phenotype',
}

export default {
  component: Pheno,
  PhenoBI,
  PhenoNO,
  DrivesOE,
  title: 'Table|Widgets/Phenotypes/Gene page',
}

export const Phenotype_daf8 = () => <Pheno targetUrl={targetUrl.daf8} />
export const Phenotype_daf16 = () => <Pheno targetUrl={targetUrl.daf16} />
export const PhenotypeByInteraction = () => <PhenoBI />
export const PhenotypeNotObserved = () => <PhenoNO />
export const DrivesOverexpression = () => <DrivesOE />
