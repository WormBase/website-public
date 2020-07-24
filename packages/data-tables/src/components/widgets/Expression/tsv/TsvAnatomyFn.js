import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'
import { generateHeaders } from '../../../../util/tsvHelper'

const TsvAnatomyFn = ({ data, id }) => {
  const toBeHeaderArr = [
    'bp_inv.text',
    'bp_inv.evidence',
    'assay.text',
    'assay.evidence',
    'phenotype',
    'reference',
  ]

  const headers = generateHeaders(toBeHeaderArr)

  const processedData = data.map((d) => {
    const copyOfD = cloneDeep(d)
    copyOfD.bp_inv.text = `${copyOfD.bp_inv.text.label}[${copyOfD.bp_inv.text.id}]`
    copyOfD.bp_inv.evidence = `${Object.keys(
      copyOfD.bp_inv.evidence
    )}:${Object.values(copyOfD.bp_inv.evidence)}`

    copyOfD.assay.evidence = `${Object.keys(
      copyOfD.assay.evidence
    )}:${Object.values(copyOfD.assay.evidence)}`

    copyOfD.phenotype = `${copyOfD.phenotype.label}[${copyOfD.phenotype.id}]`
    copyOfD.reference = `${copyOfD.reference.label}[${copyOfD.reference.id}]`

    return copyOfD
  })

  return (
    <CSVLink
      data={processedData}
      headers={headers}
      separator={'\t'}
      filename={`${id}.tsv`}
    >
      Save table as TSV
    </CSVLink>
  )
}

export default TsvAnatomyFn
