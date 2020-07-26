import React, { useMemo } from 'react'
import Table from '../../Table'
import { decideHeader } from '../../../util/columnsHelper'
import {
  sortByInteractions,
  sortByCitations,
} from '../../../util/sortTypeHelper'
import Tsv from '../../Tsv'

const PhenotypeByInteraction = ({ data, id, columnsHeader }) => {
  const showInteractions = (value) => {
    return value.map((detail, idx) => (
      <ul key={idx}>
        <li>{detail.label}</li>
      </ul>
    ))
  }

  const showCitations = (value) => {
    return value.map((detail, idx) => (
      <ul key={idx}>
        <li>{detail[0]?.label ? detail[0].label : null}</li>
      </ul>
    ))
  }

  const columns = useMemo(() => {
    return [
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        accessor: 'phenotype.label',
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        accessor: 'interactions',
        Cell: ({ cell: { value } }) => showInteractions(value),
        sortType: (rowA, rowB, columnId) =>
          sortByInteractions(rowA, rowB, columnId),
        width: 200,
        minWidth: 145,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        accessor: 'interaction_type',
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        accessor: 'citations',
        Cell: ({ cell: { value } }) => showCitations(value),
        sortType: (rowA, rowB, columnId) =>
          sortByCitations(rowA, rowB, columnId),
        minWidth: 240,
        width: 400,
      },
    ]
  }, [columnsHeader])

  return (
    <>
      <Tsv data={data} id={id} />
      <Table columns={columns} data={data} id={id} />
    </>
  )
}

export default PhenotypeByInteraction
