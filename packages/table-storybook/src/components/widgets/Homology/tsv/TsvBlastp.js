import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'
import { generateHeaders } from '../../../../util/tsvHelper'

const TsvBlastp = ({ data, WBid, tableType }) => {
  const selectToBeHeaderArr = (tableType) => {
    if (tableType === 'best_blastp_matches') {
      return [
        'evalue',
        'taxonomy.genus',
        'taxonomy.species',
        'hit',
        'description',
        'percent',
      ]
    }
    if (tableType === 'blastp_details') {
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
      return []
    }
  }

  const toBeHeaderArr = selectToBeHeaderArr(tableType)

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
      filename={`${WBid}_${tableType}.tsv`}
    >
      Save table as TSV
    </CSVLink>
  )
}

export default TsvBlastp
