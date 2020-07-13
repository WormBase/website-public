import React, { useState, useEffect, useMemo } from 'react'
import Table from './Table'
import loadData from '../../../services/loadData'
import Evidence from './Evidence'

const ExpressedIn = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const selectHeader = (tableType) => {
    if (tableType === 'expressed_in') return 'Anatomy term'
    if (tableType === 'expressed_during') return 'Life stage'
    return null
  }

  const columns = useMemo(
    () => [
      {
        Header: selectHeader(tableType),
        Cell: ({ cell: { value } }) => value,
        accessor: 'ontology_term.label',
        minWidth: 150,
        width: 240,
      },
      {
        Header: 'Supporting Evidence',
        Cell: ({ cell: { value } }) => <Evidence evidences={value} />,
        accessor: 'details',
        minWidth: 560,
        width: 720,
        maxWidth: 800,
        sortType: 'sortByEvidence',
      },
    ],
    [tableType]
  )

  return (
    <>
      <Table columns={columns} data={data} WBid={WBid} tableType={tableType} />
    </>
  )
}

export default ExpressedIn
