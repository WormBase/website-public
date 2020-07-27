import React, { useMemo } from 'react'
import TableHasGroupedRow from '../../TableHasGroupedRow'
import { decideHeader } from '../../../util/columnsHelper'
import Allele from './Allele'
import RNAi from './RNAi'
import Entity from './Entity'
import Overexpression from './Overexpression'

const Phenotype = ({ data, id, columnsHeader }) => {
  const showEntities = (value) => {
    if (value === null) {
      return 'N/A'
    } else {
      return <Entity eObj={value} />
    }
  }

  const showEvidence = (value) => {
    if (value.Allele) {
      return <Allele aObj={value.Allele} />
    }
    if (value.RNAi) {
      return <RNAi rObj={value.RNAi} />
    }
    if (value.Transgene) {
      return <Overexpression oObj={value.Transgene} />
    } else {
      console.error(value)
      return null
    }
  }

  const columns = useMemo(
    () => [
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        accessor: 'phenotype.label',
        aggregate: 'count',
        Aggregated: ({ value }) => `${value} Names`,
        Cell: ({ cell: { value } }) => value,
        width: 240,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        accessor: 'entity',
        Cell: ({ cell: { value } }) => showEntities(value),
        disableSortBy: true,
        aggregate: 'count',
        Aggregated: () => null,
        canGroupBy: false,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        accessor: 'evidence',
        Cell: ({ cell: { value } }) => showEvidence(value),
        disableSortBy: true,
        minWidth: 240,
        width: 540,
        aggregate: 'count',
        Aggregated: () => null,
        canGroupBy: false,
      },
    ],
    [columnsHeader]
  )

  return (
    <>
      <TableHasGroupedRow columns={columns} data={data} id={id} />
    </>
  )
}

export default Phenotype
