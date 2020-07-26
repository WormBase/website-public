import React, { useMemo } from 'react'
import Table from '../../Table'
import { decideHeader } from '../../../util/columnsHelper'
import {
  numberWithScientificNotation,
  sortBySpecies,
} from '../../../util/sortTypeHelper'
import Tsv from '../../Tsv'

const Blastp = ({ data, id, columnsHeader }) => {
  const columns = useMemo(
    () => [
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => Number(value),
        accessor: 'evalue',
        sortType: (rowA, rowB, columnId) =>
          numberWithScientificNotation(rowA, rowB, columnId),
        minWidth: 80,
        width: 100,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => `${value.genus}. ${value.species}`,
        accessor: 'taxonomy',
        sortType: (rowA, rowB, columnId) => sortBySpecies(rowA, rowB, columnId),
        width: 170,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'hit.label',
        minWidth: 250,
        width: 270,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'description',
        minWidth: 300,
        width: 320,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => Number(value),
        accessor: 'percent',
        minWidth: 80,
        width: 100,
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

export default Blastp
