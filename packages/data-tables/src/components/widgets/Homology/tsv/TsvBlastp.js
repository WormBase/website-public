import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'
import { generateHeaders } from '../../../../util/tsvHelper'

const TsvBlastp = ({ data, id }) => {
  const selectToBeHeaderArr = (id) => {
    if (id === 'table_best_blastp_matches') {
      return [
        'evalue',
        'taxonomy.genus',
        'taxonomy.species',
        'hit',
        'description',
        'percent',
      ]
    }
    if (id === 'table_blastp_details') {
      return [
        'evalue',
        'taxonomy.genus',
        'taxonomy.species',
        'hit',
        'description',
        'percentage',
        'source_range',
        'target_range',
      ]
    } else {
      console.error('An improper id was passed')
      return []
    }
  }

  const toBeHeaderArr = selectToBeHeaderArr(id)

  const headers = generateHeaders(toBeHeaderArr)

  const processedData = data.map((d) => {
    const copyOfD = cloneDeep(d)
    copyOfD.hit = `${copyOfD.hit.label}[${copyOfD.hit.id}]`

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

export default TsvBlastp
