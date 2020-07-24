import React, { useMemo } from 'react'
import Table from './Table'
// import { sortByCitations } from '../../../services/loadData'
import { decideHeader } from '../../../util/columnsHelper'

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
        sortType: 'sortByInteractions',
        disableFilters: true,
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
        sortType: 'sortByCitations',
        // sortType: (rowA, rowB, columnId) =>
        //   sortByCitations(rowA, rowB, columnId),
        disableFilters: true,
        minWidth: 240,
        width: 400,
      },
    ]
  }, [columnsHeader])

  return (
    <>
      <Table columns={columns} data={data} id={id} />
    </>
  )
}

export default PhenotypeByInteraction
