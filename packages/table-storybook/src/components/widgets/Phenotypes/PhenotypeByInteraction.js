import React, { useState, useEffect, useMemo } from 'react'
import Table from './Table'
import loadData from '../../../services/loadData'

const PhenotypeByInteraction = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => setData(json.data))
  }, [WBid, tableType])

  const showInteractions = (value) => {
    return value.map((detail, idx) => (
      <ul key={idx}>
        <li>{detail.label}</li>
      </ul>
    ))
  }

  const showCitations = (value) => {
    return value.map((detail, idx) => (
      <ul key={idx}>
        <li>{detail[0]?.label ? detail[0].label : null}</li>
      </ul>
    ))
  }

  const columns = useMemo(
    () => [
      {
        Header: 'Phenotype',
        accessor: 'phenotype.label',
      },
      {
        Header: 'Interactions',
        accessor: 'interactions',
        Cell: ({ cell: { value } }) => showInteractions(value),
        disableFilters: true,
        disableSortBy: true,
        width: 200,
        minWidth: 145,
      },
      {
        Header: 'Interaction Type',
        accessor: 'interaction_type',
        disableSortBy: true,
      },
      {
        Header: 'Citations',
        accessor: 'citations',
        Cell: ({ cell: { value } }) => showCitations(value),
        disableFilters: true,
        disableSortBy: true,
        minWidth: 240,
        width: 400,
      },
    ],
    []
  )

  return (
    <>
      <Table columns={columns} data={data} WBid={WBid} tableType={tableType} />
    </>
  )
}

export default PhenotypeByInteraction
