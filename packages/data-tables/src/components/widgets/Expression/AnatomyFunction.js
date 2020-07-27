import React, { useMemo } from 'react'
import Table from '../../Table'
import { decideHeader } from '../../../util/columnsHelper'
import {
  sortByAnatomicalSites,
  sortByDescriptionType0,
} from '../../../util/sortTypeHelper'

const ExpressionCluster = ({ data, id, columnsHeader }) => {
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
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => showAnatomicalSites(value),
        accessor: 'bp_inv',
        sortType: (rowA, rowB, columnId) =>
          sortByAnatomicalSites(rowA, rowB, columnId),
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => showAssay(value),
        accessor: 'assay',
        sortType: (rowA, rowB, columnId) =>
          sortByDescriptionType0(rowA, rowB, columnId),
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'phenotype.label',
        minWidth: 200,
        width: 280,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'reference.label',
        minWidth: 250,
        width: 320,
      },
    ],
    [columnsHeader]
  )

  return (
    <>
      <Table columns={columns} data={data} id={id} />
    </>
  )
}

export default ExpressionCluster
