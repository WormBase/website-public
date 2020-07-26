import React, { useMemo } from 'react'
import Table from '../../Table'
import { decideHeader } from '../../../util/columnsHelper'
import {
  numberWithScientificNotation,
  sortBySpecies,
} from '../../../util/sortTypeHelper'
import Tsv from '../../Tsv'

const BlastpDetails = ({ data, id, columnsHeader }) => {
  const columns = useMemo(
    () => [
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => Number(value),
        accessor: 'evalue',
        sortType: (rowA, rowB, columnId) =>
          numberWithScientificNotation(rowA, rowB, columnId),
        minWidth: 90,
        width: 90,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => `${value.genus}. ${value.species}`,
        accessor: 'taxonomy',
        sortType: (rowA, rowB, columnId) => sortBySpecies(rowA, rowB, columnId),
        minWidth: 120,
        width: 120,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'hit.label',
        minWidth: 250,
        width: 250,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'description',
        minWidth: 250,
        width: 250,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => (value === null ? '' : Number(value)),
        accessor: 'percentage',
        minWidth: 70,
        width: 70,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'target_range',
        minWidth: 80,
        width: 90,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'source_range',
        minWidth: 80,
        width: 90,
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

export default BlastpDetails
