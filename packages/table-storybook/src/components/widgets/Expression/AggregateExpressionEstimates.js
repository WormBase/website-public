import React, { useState, useEffect, useMemo } from 'react'
import Table from './Table'
import loadData from '../../../services/loadData'

const AggregateExpressionEstimates = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data.controls)
    })
  }, [WBid, tableType])

  const showMedianAndMean = (value) => {
    return (
      <>
        <div>{value.text}</div>
        <b>{Object.keys(value.evidence)}:</b>{' '}
        <span>{Object.values(value.evidence)}</span>
      </>
    )
  }

  const columns = useMemo(
    () => [
      {
        Header: 'Life stage',
        Cell: ({ cell: { value } }) => value,
        accessor: 'life_stage.label',
      },
      {
        Header: 'Median',
        Cell: ({ cell: { value } }) => showMedianAndMean(value),
        accessor: 'control median',
        minWidth: 300,
        width: 390,
        sortType: 'sortByMedianOrMean',
      },
      {
        Header: 'Mean',
        Cell: ({ cell: { value } }) => showMedianAndMean(value),
        accessor: 'control mean',
        minWidth: 300,
        width: 390,
        sortType: 'sortByMedianOrMean',
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

export default AggregateExpressionEstimates
