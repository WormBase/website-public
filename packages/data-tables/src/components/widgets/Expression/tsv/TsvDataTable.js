import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'
import { generateHeaders } from '../../../../util/tsvHelper'

const TsvDataTable = ({ data, id }) => {
  const toBeHeaderArr = ['value', 'life_stage', 'project_info', 'label']

  const headers = generateHeaders(toBeHeaderArr)

  const processedData = data.map((d) => {
    const copyOfD = cloneDeep(d)
    copyOfD.life_stage = `${copyOfD.life_stage.label}[${copyOfD.life_stage.id}]`
    copyOfD.project_info = `${copyOfD.project_info.label}[${copyOfD.project_info.id}]`
    copyOfD.label = `${copyOfD.label.label}[${copyOfD.label.id}]`

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

export default TsvDataTable
