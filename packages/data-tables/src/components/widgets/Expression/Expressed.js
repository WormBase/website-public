import React, { useMemo } from 'react'
import Table from '../../Table'
import { decideHeader } from '../../../util/columnsHelper'
import { sortByEvidence } from '../../../util/sortTypeHelper'
import Evidence from './Evidence'
import TsvExpressed from './tsv/TsvExpressed'

const Expressed = ({ data, id, columnsHeader }) => {
  // const selectHeader = (tableType) => {
  //   if (tableType === 'expressed_in') return 'Anatomy term'
  //   if (tableType === 'expressed_during') return 'Life stage'
  //   if (tableType === 'subcellular_localization') return 'Cellular component'
  //   return null
  // }

  const columns = useMemo(
    () => [
      {
        // Header: selectHeader(tableType),
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'ontology_term.label',
        minWidth: 150,
        width: 240,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => <Evidence evidences={value} />,
        accessor: 'details',
        minWidth: 560,
        width: 720,
        maxWidth: 800,
        sortType: (rowA, rowB, columnId) =>
          sortByEvidence(rowA, rowB, columnId),
      },
    ],
    [columnsHeader]
  )

  return (
    <>
      <TsvExpressed data={data} id={id} />
      <Table columns={columns} data={data} id={id} />
    </>
  )
}

export default Expressed
