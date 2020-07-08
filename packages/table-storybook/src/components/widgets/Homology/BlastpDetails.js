import React, { useState, useEffect, useMemo } from 'react'
import Table from './Table'
import loadData from '../../../services/loadData'

const BlastpDetails = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const columns = useMemo(
    () => [
      {
        Header: 'BLAST e-value',
        Cell: ({ cell: { value } }) => Number(value),
        accessor: 'evalue',
        sortType: 'numberWithScientificNotation',
        minWidth: 90,
        width: 90,
      },
      {
        Header: 'Species',
        Cell: ({ cell: { value } }) => `${value.genus}. ${value.species}`,
        accessor: 'taxonomy',
        minWidth: 120,
        width: 120,
      },
      {
        Header: 'Hit',
        Cell: ({ cell: { value } }) => value,
        accessor: 'hit.label',
        minWidth: 250,
        width: 250,
      },
      {
        Header: 'Description',
        Cell: ({ cell: { value } }) => value,
        accessor: 'description',
        minWidth: 250,
        width: 250,
      },
      {
        Header: '% Length',
        Cell: ({ cell: { value } }) => (value === null ? '' : Number(value)),
        accessor: 'percentage',
        minWidth: 70,
        width: 70,
      },
      {
        Header: 'Target range',
        Cell: ({ cell: { value } }) => value,
        accessor: 'target_range',
        minWidth: 80,
        width: 90,
      },
      {
        Header: 'Source range',
        Cell: ({ cell: { value } }) => value,
        accessor: 'source_range',
        minWidth: 80,
        width: 90,
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

export default BlastpDetails
