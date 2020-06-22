import React from 'react'
import { CSVLink } from 'react-csv'

const Csv = ({ data }) => {
  const headers = [
    // phenotype
    { label: 'phenotype.class', key: 'phenotype.class' },
    { label: 'phenotype.id', key: 'phenotype.id' },
    { label: 'phenotype.label', key: 'phenotype.label' },
    { label: 'phenotype.taxonomy', key: 'phenotype.taxonomy' },

    // entity
    { label: 'entity', key: 'entity' },

    // evidence
    // '_' denotes 'Allele' or 'RNAi'
    { label: 'evidence', key: 'evidence.type' },
    { label: 'evidence._.text.class', key: 'evidence.text.class' },
    { label: 'evidence._.text.id', key: 'evidence.text.id' },
    { label: 'evidence._.text.label', key: 'evidence.text.label' },
    { label: 'evidence._.text.taxonomy', key: 'evidence.text.taxonomy' },
    { label: 'evidence._.evidence', key: 'evidence.evi' },
  ]

  const processedData = data.map((d) => {
    const shallowCopyOfD = { ...d }

    // Handling 'entity'
    if (shallowCopyOfD.entity === null) {
      shallowCopyOfD.entity = 'N/A'
    } else {
      shallowCopyOfD.entity = JSON.stringify(shallowCopyOfD.entity)
    }

    // Handling 'evidence'
    const keyOfEvidence = Object.keys(shallowCopyOfD.evidence) // 'Allele' or 'RNAi'

    shallowCopyOfD.evidence = shallowCopyOfD.evidence[keyOfEvidence]
    shallowCopyOfD.evidence.type = keyOfEvidence

    // WARNING! Don't assign to object property 'shallowCopyOfD.evidence.evidence'.
    // It will change original data props (I imagine).
    // So, instead I use 'shallowCopyOfD.evidence.evi'
    shallowCopyOfD.evidence.evi = JSON.stringify(
      shallowCopyOfD.evidence.evidence
    )

    return shallowCopyOfD
  })

  return (
    <div>
      <CSVLink data={processedData} headers={headers}>
        Save table
      </CSVLink>
    </div>
  )
}

export default Csv
