import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'

const Csv = ({ data, WBid, tableType }) => {
  const headers = [
    // phenotype
    { label: 'phenotype.class', key: 'phenotype.class' },
    { label: 'phenotype.id', key: 'phenotype.id' },
    { label: 'phenotype.label', key: 'phenotype.label' },
    { label: 'phenotype.taxonomy', key: 'phenotype.taxonomy' },

    // entity
    { label: 'entity', key: 'entity' },

    // evidence

    // For 'Allele'
    {
      label: 'evidence.Allele.evidence.Affected_by_molecule',
      key: 'evidence.Allele.evidence.Affected_by_molecule',
    },
    {
      label: 'evidence.Allele.evidence.Curator',
      key: 'evidence.Allele.evidence.Curator',
    },
    {
      label: 'evidence.Allele.evidence.Ease_of_scoring',
      key: 'evidence.Allele.evidence.Ease_of_scoring',
    },
    {
      label: 'evidence.Allele.evidence.Paper_evidence',
      key: 'evidence.Allele.evidence.Paper_evidence',
    },
    {
      label: 'evidence.Allele.evidence.Person_evidence',
      key: 'evidence.Allele.evidence.Person_evidence',
    },
    {
      label: 'evidence.Allele.evidence.Remark',
      key: 'evidence.Allele.evidence.Remark',
    },
    {
      label: 'evidence.Allele.evidence.Temperature',
      key: 'evidence.Allele.evidence.Temperature',
    },
    {
      label: 'evidence.Allele.evidence.Temperature_sensitive',
      key: 'evidence.Allele.evidence.Temperature_sensitive',
    },
    {
      label: 'evidence.Allele.evidence.Treatment',
      key: 'evidence.Allele.evidence.Treatment',
    },
    {
      label: 'evidence.Allele.evidence.Variation_effect',
      key: 'evidence.Allele.evidence.Variation_effect',
    },
    {
      label: 'evidence.Allele.evidence.Recessive',
      key: 'evidence.Allele.evidence.Recessive',
    },
    {
      label: 'evidence.Allele.evidence.Penetrance',
      key: 'evidence.Allele.evidence.Penetrance',
    },
    {
      label: 'evidence.Allele.evidence.Penetrance-range',
      key: 'evidence.Allele.evidence.Penetrance-range',
    },

    { label: 'evidence.Allele.text.class', key: 'evidence.Allele.text.class' },
    { label: 'evidence.Allele.text.id', key: 'evidence.Allele.text.id' },
    { label: 'evidence.Allele.text.label', key: 'evidence.Allele.text.label' },
    {
      label: 'evidence.Allele.text.taxonomy',
      key: 'evidence.Allele.text.taxonomy',
    },

    // For 'RNAi'
    {
      label: 'evidence.RNAi.evidence.Affected_by_molecule',
      key: 'evidence.RNAi.evidence.Affected_by_molecule',
    },
    {
      label: 'evidence.RNAi.evidence.Genotype',
      key: 'evidence.RNAi.evidence.Genotype',
    },

    // "paper" is not observed in rest-staging API
    // {
    //   label: 'evidence.RNAi.evidence.paper',
    //   key: 'evidence.RNAi.evidence.paper',
    // },

    {
      label: 'evidence.RNAi.evidence.Paper_evidence',
      key: 'evidence.RNAi.evidence.Paper_evidence',
    },
    {
      label: 'evidence.RNAi.evidence.Penetrance-range',
      key: 'evidence.RNAi.evidence.Penetrance-range',
    },
    {
      label: 'evidence.RNAi.evidence.Quantity_description',
      key: 'evidence.RNAi.evidence.Quantity_description',
    },
    {
      label: 'evidence.RNAi.evidence.Remark',
      key: 'evidence.RNAi.evidence.Remark',
    },
    {
      label: 'evidence.RNAi.evidence.Strain',
      key: 'evidence.RNAi.evidence.Strain',
    },

    { label: 'evidence.RNAi.text.class', key: 'evidence.RNAi.text.class' },
    { label: 'evidence.RNAi.text.id', key: 'evidence.RNAi.text.id' },
    { label: 'evidence.RNAi.text.label', key: 'evidence.RNAi.text.label' },
    {
      label: 'evidence.RNAi.text.taxonomy',
      key: 'evidence.RNAi.text.taxonomy',
    },
  ]

  const processedData = data.map((d) => {
    const copyOfD = cloneDeep(d)

    // Handling 'entity'
    if (copyOfD.entity === null) {
      copyOfD.entity = 'N/A'
    } else {
      const keyOfEntity = Object.keys(copyOfD.entity)
      copyOfD.entity = JSON.stringify(copyOfD.entity[keyOfEntity])
    }

    // Handling 'evidence'
    const keyOfEvidence = Object.keys(copyOfD.evidence) // 'Allele' or 'RNAi'

    const evidenceSpecific = copyOfD.evidence[keyOfEvidence].evidence

    Object.entries(evidenceSpecific).forEach(([key, value]) => {
      if (Array.isArray(evidenceSpecific[key])) {
        evidenceSpecific[key] = JSON.stringify(evidenceSpecific[key])
      }

      if (
        typeof evidenceSpecific[key] === 'object' &&
        evidenceSpecific !== null
      ) {
        evidenceSpecific[key] = JSON.stringify(evidenceSpecific[key])
      }
    })

    return copyOfD
  })

  return (
    <div>
      <div>
        <CSVLink
          data={processedData}
          headers={headers}
          filename={`${WBid}_${tableType}.csv`}
        >
          Save table as CSV
        </CSVLink>
      </div>
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

export default Csv
