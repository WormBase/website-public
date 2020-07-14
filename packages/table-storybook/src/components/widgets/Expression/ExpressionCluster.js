import React, { useState, useEffect, useMemo } from 'react'
import Table from './Table'
import loadData from '../../../services/loadData'

const ExpressionCluster = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const showDescription = (value) => {
    return value.map((v, idx) =>
      idx === value.length - 1 ? (
        <span key={idx}>{v}</span>
      ) : (
        <span key={idx}>{v}; </span>
      )
    )
  }

  const columns = useMemo(
    () => [
      {
        Header: 'Expression clusters',
        Cell: ({ cell: { value } }) => value,
        accessor: 'expression_cluster.label',
        minWidth: 460,
        width: 500,
      },
      {
        Header: 'Description',
        Cell: ({ cell: { value } }) => showDescription(value),
        accessor: 'description',
        minWidth: 400,
        width: 460,
        sortType: 'sortByDescriptionType1',
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

export default ExpressionCluster
