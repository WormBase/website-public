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

  const showAnatomicalSites = (value) => {
    return (
      <>
        <div>{value.text.label}</div>
        <b>{Object.keys(value.evidence)}:</b>{' '}
        <span>{Object.values(value.evidence)}</span>
      </>
    )
  }

  const showAssay = (value) => {
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
        Header: 'Anatomical Sites',
        Cell: ({ cell: { value } }) => showAnatomicalSites(value),
        accessor: 'bp_inv',
        sortType: 'sortByAnatomicalSites',
      },
      {
        Header: 'Assay',
        Cell: ({ cell: { value } }) => showAssay(value),
        accessor: 'assay',
        sortType: 'sortByDescriptionType0',
      },
      {
        Header: 'Phenotype',
        Cell: ({ cell: { value } }) => value,
        accessor: 'phenotype.label',
        minWidth: 200,
        width: 280,
      },
      {
        Header: 'Reference',
        Cell: ({ cell: { value } }) => value,
        accessor: 'reference.label',
        minWidth: 250,
        width: 320,
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
