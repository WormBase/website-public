import React, { useMemo } from 'react'
import Table from '../../Table'
import { decideHeader } from '../../../util/columnsHelper'
import { sortByMedianOrMean } from '../../../util/sortTypeHelper'
import TsvDataCtrl from './tsv/TsvDataCtrl'

const AggregateExpressionEstimates = ({ data, id, columnsHeader }) => {
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
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'life_stage.label',
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => showMedianAndMean(value),
        accessor: 'control median',
        minWidth: 300,
        width: 390,
        sortType: (rowA, rowB, columnId) =>
          sortByMedianOrMean(rowA, rowB, columnId),
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => showMedianAndMean(value),
        accessor: 'control mean',
        minWidth: 300,
        width: 390,
        sortType: (rowA, rowB, columnId) =>
          sortByMedianOrMean(rowA, rowB, columnId),
      },
    ],
    [columnsHeader]
  )

  return (
    <>
      <TsvDataCtrl data={data} id={id} />
      <Table columns={columns} data={data} id={id} />
    </>
  )
}

export default AggregateExpressionEstimates
