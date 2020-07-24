import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'
import unwind from 'javascript-unwind'
import {
  generateHeaders,
  generateDerivedHeaders,
} from '../../../../util/tsvHelper'

const TsvExpressed = ({ data, id }) => {
  const toBeHeaderArr = ['ontology_term', 'images', 'details.text']

  const objKeysOfDetails = [
    'Algorithm',
    'Citation',
    'Description',
    'Expressed_during',
    'Expressed_in',
    'Method of analysis, Microarray',
    'Method_of_isolation',
    'Paper',
    'Reagents',
    'Type',
  ]

  const headers = [
    ...generateHeaders(toBeHeaderArr),
    ...generateDerivedHeaders('details.evidence', objKeysOfDetails),
  ]

  const processedData =
    data.length === 0
      ? []
      : unwind(data, 'details').map((d) => {
          const copyOfD = cloneDeep(d)

          copyOfD.ontology_term = `${copyOfD.ontology_term.label}[${copyOfD.ontology_term.id}]`
          copyOfD.details.text = `${copyOfD.details.text.label}[${copyOfD.details.text.id}]`

          const collectionOfEvidences = copyOfD.details.evidence
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

export default TsvExpressed
