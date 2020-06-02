import React from 'react'
import Pheno from './Phenotype'
import PhenoBI from './PhenotypeByInteraction'
import PhenoNO from './PhenotypeNotObserved'
import DrivesOE from './DrivesOverexpression'

export default {
  component: Pheno,
  PhenoBI,
  PhenoNO,
  DrivesOE,
  title: 'Table|Widgets/Phenotypes/Gene page',
}

export const Phenotype = () => <Pheno />
export const PhenotypeByInteraction = () => <PhenoBI />
export const PhenotypeNotObserved = () => <PhenoNO />
export const DrivesOverexpression = () => <DrivesOE />
