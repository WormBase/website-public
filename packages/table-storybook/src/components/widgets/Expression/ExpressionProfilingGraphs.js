import React, { useState, useEffect, useMemo } from 'react'
import Table from './Table'
import loadData from '../../../services/loadData'

const ExpressedProfillingGraphs = ({ WBid, tableType }) => {
  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => {
      setData(json.data)
    })
  }, [WBid, tableType])

  const showDescription = (value) => {
    return (
      <>
        <div>{value.text}</div>
        {Object.entries(value.evidence).map(([key, val], idx1) => {
          return (
            <div key={idx1}>
              <b>{key}: </b>
              {val.map((v, idx2) => {
                return idx2 === value.evidence[`${key}`].length - 1 ? (
                  <span key={idx2}>{v.label}</span>
                ) : (
                  <span key={idx2}>{v.label}; </span>
                )
              })}
            </div>
          )
        })}
      </>
    )
  }

  const showDatabase = (value) => {
    if (!value) {
      return null
    }
    return value.map((v, idx) =>
      idx === value.length - 1 ? (
        <span key={idx}>{v.label}</span>
      ) : (
        <span key={idx}>{v.label}; </span>
      )
    )
  }

  const columns = useMemo(
    () => [
      {
        Header: 'Pattern',
        Cell: ({ cell: { value } }) => value,
        accessor: 'expression_pattern.label',
        minWidth: 100,
        width: 150,
      },
      {
        Header: 'Type',
        Cell: ({ cell: { value } }) => value,
        accessor: 'type[0]',
        minWidth: 100,
        width: 150,
      },
      {
        Header: 'Description',
        Cell: ({ cell: { value } }) => showDescription(value),
        accessor: 'description',
        minWidth: 450,
        width: 510,
        sortType: 'sortByDescriptionType0',
      },
      {
        Header: 'Database',
        Cell: ({ cell: { value } }) => showDatabase(value),
        accessor: 'database',
        minWidth: 100,
        width: 150,
        sortType: 'sortByDatabase',
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

export default ExpressedProfillingGraphs
