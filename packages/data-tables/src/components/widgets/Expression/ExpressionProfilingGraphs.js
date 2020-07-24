import React, { useMemo } from 'react'
import Table from '../../Table'
import { decideHeader } from '../../../util/columnsHelper'
import {
  sortByDescriptionType0,
  sortByDatabase,
} from '../../../util/sortTypeHelper'
import TsvExpProfGraphs from './tsv/TsvExpProfGraphs'

const ExpressedProfillingGraphs = ({ data, id, columnsHeader }) => {
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
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'expression_pattern.label',
        minWidth: 100,
        width: 150,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'type[0]',
        minWidth: 100,
        width: 150,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => showDescription(value),
        accessor: 'description',
        minWidth: 450,
        width: 510,
        sortType: (rowA, rowB, columnId) =>
          sortByDescriptionType0(rowA, rowB, columnId),
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => showDatabase(value),
        accessor: 'database',
        minWidth: 100,
        width: 150,
        sortType: (rowA, rowB, columnId) =>
          sortByDatabase(rowA, rowB, columnId),
      },
    ],
    [columnsHeader]
  )

  return (
    <>
      <TsvExpProfGraphs data={data} id={id} />
      <Table columns={columns} data={data} id={id} />
    </>
  )
}

export default ExpressedProfillingGraphs
