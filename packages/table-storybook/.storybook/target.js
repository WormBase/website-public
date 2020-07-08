const phenotype_widget = {
  WBid: {
    daf8: 'WBGene00000904',
    daf16: 'WBGene00000912',
    mig2: 'WBGene00003239',
  },
  tableType: {
    phenotype: 'phenotype',
    phenoNotObserved: 'phenotype_not_observed',
    phenoByInteraction: 'phenotype_by_interaction',
    drivesOverexpression: 'drives_overexpression',
    staging: {
      phenotype: 'phenotype_flat',
      phenoNotObserved: 'phenotype_not_observed_flat',
      drivesOverexpression: 'drives_overexpression_flat',
    },
  },
}

const homology_widget = {
  WBid: {
    daf8: 'WBGene00000904',
    daf16: 'WBGene00000912',
    mig2: 'WBGene00003239',
  },
  tableType: {
    bestBlastpMatches: 'best_blastp_matches',
    blastpDetails: 'blastp_details',
    nematodeOrthologs: 'nematode_orthologs',
    otherOrthologs: 'other_orthologs',
  },
}

export { phenotype_widget, homology_widget }
