import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'
import { generateHeaders } from '../../../../util/tsvHelper'

const TsvExpCluster = ({ data, WBid, tableType }) => {
  const toBeHeaderArr = ['expression_cluster', 'description']

  const headers = generateHeaders(toBeHeaderArr)

  const processedData = data.map((d) => {
    const copyOfD = cloneDeep(d)
    copyOfD.expression_cluster = `${copyOfD.expression_cluster.label}[${copyOfD.expression_cluster.id}]`

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

export default TsvExpCluster
