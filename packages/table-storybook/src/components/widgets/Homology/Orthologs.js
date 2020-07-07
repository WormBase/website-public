import React, { useState, useEffect, useMemo } from 'react'
import Table from './Table'
import loadData from '../../../services/loadData'

const Orthologs = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const showMethods = (value) => {
    return (
      <ul>
        {value.map((v, idx) => (
          <li key={idx}>{v.label}</li>
        ))}
      </ul>
    )
  }

  const columns = useMemo(
    () => [
      {
        Header: 'Species',
        Cell: ({ cell: { value } }) => `${value.genus}. ${value.species}`,
        accessor: 'species',
        sortType: 'sortBySpecies',
      },
      {
        Header: 'Ortholog',
        Cell: ({ cell: { value } }) => value,
        accessor: 'ortholog.label',
        minWidth: 290,
        width: 390,
      },
      {
        Header: 'Method',
        Cell: ({ cell: { value } }) => showMethods(value),
        accessor: 'method',
        minWidth: 200,
        width: 390,
        sortType: 'sortByMethods',
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

export default Orthologs
