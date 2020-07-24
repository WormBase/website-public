import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'
import {
  generateHeaders,
  generateDerivedHeaders,
} from '../../../../util/tsvHelper'

const TsvExpProfGraphs = ({ data, id }) => {
  const toBeHeaderArr = [
    'expression_pattern',
    'type',
    'description.text',
    'database',
  ]

  const objKeysOfDescription = ['Reference']

  const headers = [
    ...generateHeaders(toBeHeaderArr),
    ...generateDerivedHeaders('description.evidence', objKeysOfDescription),
  ]

  const processedData = data.map((d) => {
    const copyOfD = cloneDeep(d)
    copyOfD.expression_pattern = `${copyOfD.expression_pattern.label}[${copyOfD.expression_pattern.id}]`

    if (copyOfD.database !== null) {
      const separetedDbArr = copyOfD.database.map((a) => `${a.label}[${a.id}]`)
      copyOfD.database = separetedDbArr.join(';')
    }

    const collectionOfEvidences = copyOfD.description.evidence
    Object.entries(collectionOfEvidences).forEach(([key, value]) => {
      const specificEvidence = collectionOfEvidences[key]
      if (typeof specificEvidence[0] === 'object') {
        const tagTypeEvidenceArr = specificEvidence.map(
          (s) => `${s.label}[${s.id}]`
        )
        collectionOfEvidences[key] = tagTypeEvidenceArr.join(';')
      } else if (Array.isArray(specificEvidence)) {
        collectionOfEvidences[key] = specificEvidence.join(';')
      } else if (typeof specificEvidence === 'object') {
        collectionOfEvidences[
          key
        ] = `${specificEvidence.label}[${specificEvidence.id}]`
      }
    })

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

export default TsvExpProfGraphs
