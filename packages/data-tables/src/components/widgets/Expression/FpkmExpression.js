import React, { useState, useEffect, useMemo } from 'react'
import Table from './Table'
import loadData from '../../../services/loadData'

const FpkmExpression = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data.table.fpkm.data)
    })
  }, [WBid, tableType])

  const columns = useMemo(
    () => [
      {
        Header: 'Name',
        Cell: ({ cell: { value } }) => value,
        accessor: 'label.label',
        minWidth: 200,
        width: 900,
        maxWidth: 1500,
      },
      {
        Header: 'Project',
        Cell: ({ cell: { value } }) => value,
        accessor: 'project_info.label',
        minWidth: 240,
        width: 300,
      },
      {
        Header: 'Life stage',
        Cell: ({ cell: { value } }) => value,
        accessor: 'life_stage.label',
      },
      {
        Header: 'FPKM value',
        Cell: ({ cell: { value } }) => value,
        accessor: 'value',
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

export default FpkmExpression
