import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'
import { generateHeaders } from '../../../../util/tsvHelper'

const TsvOrthologs = ({ data, id }) => {
  const toBeHeaderArr = [
    'species.genus',
    'species.species',
    'ortholog',
    'method',
  ]

  const headers = generateHeaders(toBeHeaderArr)

  const processedData = data.map((d) => {
    const copyOfD = cloneDeep(d)
    copyOfD.ortholog = `${copyOfD.ortholog.label}[${copyOfD.ortholog.id}]`

    const separetedMethodsArr = copyOfD.method.map((m) => `${m.label}[${m.id}]`)
    copyOfD.method = separetedMethodsArr.join(';')

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

export default TsvOrthologs
