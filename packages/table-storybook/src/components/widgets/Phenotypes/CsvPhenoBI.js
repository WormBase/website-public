import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'

const CsvPhenoBI = ({ data, WBid, tableType }) => {
  const generateHeaders = (labelAndKeyArr) =>
    labelAndKeyArr.map((lk) => {
      return {
        label: lk,
        key: lk,
      }
    })

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
    <div>
      <div>
        <CSVLink
          data={processedData}
          headers={headers}
          separator={'\t'}
          filename={`${WBid}_${tableType}.tsv`}
        >
          Save table as TSV
        </CSVLink>
      </div>
    </div>
  )
}

export default CsvPhenoBI
