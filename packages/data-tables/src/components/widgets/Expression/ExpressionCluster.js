import React, { useMemo } from 'react'
import Table from '../../Table'
import { decideHeader } from '../../../util/columnsHelper'
import { sortByDescriptionType1 } from '../../../util/sortTypeHelper'
import Tsv from '../../Tsv'

const ExpressionCluster = ({ data, id, columnsHeader }) => {
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
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'expression_cluster.label',
        minWidth: 460,
        width: 500,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => showDescription(value),
        accessor: 'description',
        minWidth: 400,
        width: 460,
        sortType: (rowA, rowB, columnId) =>
          sortByDescriptionType1(rowA, rowB, columnId),
      },
    ],
    [columnsHeader]
  )

  return (
    <>
      <Tsv data={data} id={id} />
      <Table columns={columns} data={data} id={id} />
    </>
  )
}

export default ExpressionCluster
