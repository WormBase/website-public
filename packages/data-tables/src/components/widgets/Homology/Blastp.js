import React, { useState, useEffect, useMemo } from 'react'
import Table from './Table'
import loadData from '../../../services/loadData'

const Blastp = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data.hits)
    })
  }, [WBid, tableType])

  const columns = useMemo(
    () => [
      {
        Header: 'BLAST e-value',
        Cell: ({ cell: { value } }) => Number(value),
        accessor: 'evalue',
        sortType: 'scientificNotation',
        minWidth: 80,
        width: 100,
      },
      {
        Header: 'Species',
        Cell: ({ cell: { value } }) => `${value.genus}. ${value.species}`,
        accessor: 'taxonomy',
        width: 170,
      },
      {
        Header: 'Hit',
        Cell: ({ cell: { value } }) => value,
        accessor: 'hit.label',
        minWidth: 250,
        width: 270,
      },
      {
        Header: 'Description',
        Cell: ({ cell: { value } }) => value,
        accessor: 'description',
        minWidth: 300,
        width: 320,
      },
      {
        Header: '% Length',
        Cell: ({ cell: { value } }) => Number(value),
        accessor: 'percent',
        minWidth: 80,
        width: 100,
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

export default Blastp
