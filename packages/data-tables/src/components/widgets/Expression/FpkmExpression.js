import React, { useMemo } from 'react'
import Table from '../../Table'
import { decideHeader } from '../../../util/columnsHelper'

const FpkmExpression = ({ data, id, columnsHeader }) => {
  const columns = useMemo(
    () => [
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'label.label',
        minWidth: 200,
        width: 900,
        maxWidth: 1500,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'project_info.label',
        minWidth: 240,
        width: 300,
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'life_stage.label',
      },
      {
        Header: ({ column: { id } }) => decideHeader(id, columnsHeader),
        Cell: ({ cell: { value } }) => value,
        accessor: 'value',
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

export default FpkmExpression
