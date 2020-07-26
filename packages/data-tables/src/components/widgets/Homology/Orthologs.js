import React, { useMemo } from 'react'
import Table from '../../Table'
import { decideHeader } from '../../../util/columnsHelper'
import { sortBySpecies, sortByMethods } from '../../../util/sortTypeHelper'
import Tsv from '../../Tsv'

const Orthologs = ({ data, id, columnsHeader }) => {
  const showMethods = (value) => {
    return (
      <ul>
        {value.map((v, idx) => (
          <li key={idx}>{v.label}</li>
        ))}
      </ul>
    )
  }

  const columns = useMemo(
    () => [
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => `${value.genus}. ${value.species}`,
        accessor: 'species',
        sortType: (rowA, rowB, columnId) => sortBySpecies(rowA, rowB, columnId),
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'ortholog.label',
        minWidth: 290,
        width: 390,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => showMethods(value),
        accessor: 'method',
        minWidth: 200,
        width: 390,
        sortType: (rowA, rowB, columnId) => sortByMethods(rowA, rowB, columnId),
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

export default Orthologs
