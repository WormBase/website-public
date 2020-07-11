import React from 'react'
import { CSVLink } from 'react-csv'
import { cloneDeep } from 'lodash'

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

  const objKeysOfTag = ['class', 'id', 'label', 'taxonomy']

  const generateHeader = (commonPart, changeablePartsArr) =>
    changeablePartsArr.map((changeablePart) => {
      const dotNotationToBeHeader = `${commonPart}.${changeablePart}`
      return {
        label: dotNotationToBeHeader,
        key: dotNotationToBeHeader,
      }
    })

  const headers = [
    // phenotype
    ...generateHeader('phenotype', objKeysOfTag),

    // entity
    { label: 'entity', key: 'entity' },

    // evidence
    ...generateHeader('evidence.Allele.evidence', objKeysOfAllele),
    ...generateHeader('evidence.Allele.text', objKeysOfTag),
    ...generateHeader('evidence.RNAi.evidence', objKeysOfRNAi),
    ...generateHeader('evidence.RNAi.text', objKeysOfTag),
  ]

  const processedData = data.map((d) => {
    const copyOfD = cloneDeep(d)

    // Handling 'entity'
    if (copyOfD.entity === null) {
      copyOfD.entity = 'N/A'
    } else {
      const keyOfEntity = Object.keys(copyOfD.entity)
      const arrOfEntityString = copyOfD.entity[keyOfEntity].map(
        (c) =>
          `${c.pato_evidence.entity_term.label}[${c.pato_evidence.entity_term.id}] ${c.pato_evidence.pato_term}`
      )
      copyOfD.entity = arrOfEntityString.join(';')
    }

    // Handling 'evidence'
    const keyOfEvidence = Object.keys(copyOfD.evidence)[0] // 'Allele' or 'RNAi'
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
