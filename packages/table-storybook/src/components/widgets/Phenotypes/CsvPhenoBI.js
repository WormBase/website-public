import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'

const CsvPhenoBI = ({ data, WBid, tableType }) => {
  const headers = [
    // phenotype
    { label: 'phenotype.id', key: 'phenotype.id' },
    { label: 'phenotype.label', key: 'phenotype.label' },
    { label: 'phenotype.class', key: 'phenotype.class' },
    { label: 'phenotype.taxonomy', key: 'phenotype.taxonomy' },

    // interactions
    { label: 'interactions', key: 'interactions' },

    // interaction_type
    { label: 'interaction_type', key: 'interaction_type' },

    // citations
    { label: 'citations', key: 'citations' },
  ]

  const processedData = data.map((d) => {
    const copyOfD = cloneDeep(d)

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
