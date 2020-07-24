import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'
import { generateHeaders } from '../../../../util/tsvHelper'

const TsvPhenoBI = ({ data, id }) => {
  const toBeHeaderArr = [
    'phenotype',
    'interactions',
    'interaction_type',
    'citations',
  ]

  const headers = generateHeaders(toBeHeaderArr)

  const processedData = data.map((d) => {
    const copyOfD = cloneDeep(d)

    copyOfD.phenotype = `${copyOfD.phenotype.label}[${copyOfD.phenotype.id}]`

    const separetedInteractionsArr = copyOfD.interactions.map(
      (i) => `${i.label}[${i.id}]`
    )
    copyOfD.interactions = separetedInteractionsArr.join(';')

    const separetedCitationssArr = copyOfD.citations.map((c) =>
      c.length === 0 ? '' : `${c[0].label}[${c[0].id}]`
    )
    copyOfD.citations = separetedCitationssArr.join(';')

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

export default TsvPhenoBI
