const toCamel = (s) => {
  return s.replace(/([-_][a-z])/gi, ($1) => {
    return $1.toUpperCase().replace('-', '').replace('_', '')
  })
}

const composeObjWithCamelKey = (tableArr) => {
  const obj = {}
  tableArr.forEach((t) => (obj[`${toCamel(t)}`] = t))
  return obj
}

const WBid = {
  daf8: 'WBGene00000904',
  daf16: 'WBGene00000912',
  mig2: 'WBGene00003239',
}

const phenotypeTableArr = [
  'phenotype',
  'phenotype_not_observed',
  'phenotype_by_interaction',
  'drives_overexpression',
  'phenotype_flat',
  'phenotype_not_observed_flat',
  'drives_overexpression_flat',
]
const phenotype_widget = {
  WBid,
  tableType: composeObjWithCamelKey(phenotypeTableArr),
}

const homologyTableArr = [
  'best_blastp_matches',
  'blastp_details',
  'nematode_orthologs',
  'other_orthologs',
]
const homology_widget = {
  WBid,
  tableType: composeObjWithCamelKey(homologyTableArr),
}

const expressionTableArr = [
  'expressed_in',
  'expressed_during',
  'subcellular_locarization',
  'expression_profiling_graphs',
  'expression_cluster',
  'anatomy_function',
  'fpkm_expression_summaly_ls',
]
const expression_widget = {
  WBid,
  tableType: composeObjWithCamelKey(expressionTableArr),
}

export { phenotype_widget, homology_widget, expression_widget }
