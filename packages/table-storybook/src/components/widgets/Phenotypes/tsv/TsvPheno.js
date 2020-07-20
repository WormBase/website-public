import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'
import { generateDerivedHeaders } from '../../../../util/tsvHelper'

const CsvPheno = ({ data, WBid, tableType }) => {
  const objKeysOfAllele = [
    'Affected_by_molecule',
    'Curator',
    'Ease_of_scoring',
    'Paper_evidence',
    'Penetrance',
    'Penetrance-range',
    'Person_evidence',
    'Recessive',
    'Remark',
    'Temperature',
    'Temperature_sensitive',
    'Treatment',
    'Variation_effect',
  ]

  const objKeysOfRNAi = [
    'Affected_by_molecule',
    'Genotype',
    'Paper_evidence',
    'Penetrance-range',
    'Quantity_description',
    'Remark',
    'Strain',
  ]

  const headers = [
    // phenotype
    { label: 'phenotype', key: 'phenotype' },

    // entity
    { label: 'entity', key: 'entity' },

    // evidence
    ...generateDerivedHeaders('evidence.Allele.evidence', objKeysOfAllele),
    { label: 'evidence.Allele.text', key: 'evidence.Allele.text' },
    ...generateDerivedHeaders('evidence.RNAi.evidence', objKeysOfRNAi),
    { label: 'evidence.RNAi.text', key: 'evidence.RNAi.text' },
  ]

  const processedData = data.map((d) => {
    const copyOfD = cloneDeep(d)

    // Handling 'phenotype'
    copyOfD.phenotype = `${copyOfD.phenotype.label}[${copyOfD.phenotype.id}]`

    // Handling 'entity'
    if (copyOfD.entity !== null) {
      const keyOfEntity = Object.keys(copyOfD.entity)
      const arrOfEntityString = copyOfD.entity[keyOfEntity].map(
        (c) =>
          `${c.pato_evidence.entity_term.label}[${c.pato_evidence.entity_term.id}] ${c.pato_evidence.pato_term}`
      )
      copyOfD.entity = arrOfEntityString.join(';')
    }

    // Handling 'evidence'
    const keyOfEvidence = Object.keys(copyOfD.evidence)[0] // 'Allele' or 'RNAi'

    const evidenceText = copyOfD.evidence[keyOfEvidence].text
    copyOfD.evidence[
      keyOfEvidence
    ].text = `${evidenceText.label}[${evidenceText.id}]`

    const collectionOfEvidences = copyOfD.evidence[keyOfEvidence].evidence
    Object.entries(collectionOfEvidences).forEach(([key, value]) => {
      const specificEvidence = collectionOfEvidences[key]
      if (typeof specificEvidence[0] === 'object') {
        const tagTypeEvidenceArr = specificEvidence.map(
          (s) => `${s.label}[${s.id}]`
        )
        collectionOfEvidences[key] = tagTypeEvidenceArr.join(';')
      } else if (Array.isArray(specificEvidence)) {
        collectionOfEvidences[key] = specificEvidence.join(';')
      } else if (typeof specificEvidence === 'object') {
        collectionOfEvidences[
          key
        ] = `${specificEvidence.label}[${specificEvidence.id}]`
      }
    })

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

export default CsvPheno
