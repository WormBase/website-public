import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'
import { generateHeaders } from '../../../../util/tsvHelper'

const TsvDataCtrl = ({ data, WBid, tableType }) => {
  const toBeHeaderArr = [
    'life_stage',
    'control median.text',
    'control median.evidence.comment',
    'control mean.text',
    'control mean.evidence.comment',
  ]

  const headers = generateHeaders(toBeHeaderArr)

  const processedData = data.map((d) => {
    const copyOfD = cloneDeep(d)
    copyOfD.life_stage = `${copyOfD.life_stage.label}[${copyOfD.life_stage.id}]`

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

export default TsvDataCtrl
