import React, { useState, useEffect, useMemo } from 'react'
import Table from './Table'
import Allele from './Allele'
import RNAi from './RNAi'
import Entity from './Entity'
import loadData from '../../../../../services/loadData'

const Phenotype = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      console.log(json.data)
      setData(json.data)
    })
  }, [WBid, tableType])

  const showEntities = (value) => {
    if (value === null) {
      return 'N/A'
    } else {
      return <Entity eObj={value} />
    }
  }

  const showEvidence = (value) => {
    if (value.Allele) {
      return <Allele aObj={value.Allele} />
    }
    if (value.RNAi) {
      return <RNAi rObj={value.RNAi} />
    } else {
      console.error(value)
      return null
    }
  }

  const columns = useMemo(
    () => [
      {
        Header: 'Phenotype',
        accessor: 'phenotype.label',
        aggregate: 'count',
        Aggregated: ({ value }) => `${value} Names`,
        Cell: ({ cell: { value } }) => value,
      },
      {
        Header: 'Entities Affected',
        accessor: 'entity',
        Cell: ({ cell: { value } }) => showEntities(value),
        disableSortBy: true,
        filter: 'entitiesFilter',
        sortType: 'sortByEntity',
        aggregate: 'count',
        Aggregated: () => null,
        canGroupBy: false,
      },
      {
        Header: 'Supporting Evidence',
        accessor: 'evidence',
        Cell: ({ cell: { value } }) => showEvidence(value),
        disableSortBy: true,
        filter: 'evidenceFilter',
        minWidth: 240,
        width: 540,
        aggregate: 'count',
        Aggregated: () => null,
        canGroupBy: false,
      },
    ],
    []
  )

  return (
    <>
      <Table columns={columns} data={data} tableType={tableType} />
    </>
  )
}

export default Phenotype
