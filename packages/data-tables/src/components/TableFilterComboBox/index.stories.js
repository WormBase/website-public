import React, { useState, useEffect, useMemo } from 'react'
import TableFilterComboBox, { useWormBaseTableFilter } from './index'
import { useTable, useGlobalFilter } from 'react-table'
import loadData from '../../services/loadData';

export default {
  title: 'Misc/Table Filter Combo Box',
};

export const mock = () => (
  <TableFilterComboBox options={{
    food: ['bread', 'egg', 'lettuce', 'tomato'],
    drinks: ['water', 'soda', 'milk'],
  }} />
);

const CellDefault = ({value}) => <pre>{JSON.stringify(value, null, 2)}</pre>

const GenericTestTable = ({
  data,
  columns: columnsRaw,
}) => {

  const {
    filters,
    setFilters,
    options,
    tableOptions,
  } = useWormBaseTableFilter(data);

  const columns = useMemo(() => {
    return columnsRaw.map(columnRaw => ({
      Header: columnRaw.accessor,
      Cell: CellDefault,
      ...columnRaw,
    }))
  }, [columnsRaw])

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
  } = useTable({
    ...tableOptions,
    columns,
    data,
  }, useGlobalFilter)

  return (
    <div>
      <TableFilterComboBox options={options} onChange={setFilters} />
      <pre>{JSON.stringify(filters, null, 2)}</pre>
      <table {...getTableProps()} style={{ border: 'solid 1px blue' }}>
       <thead>
         {headerGroups.map(headerGroup => (
           <tr {...headerGroup.getHeaderGroupProps()}>
             {headerGroup.headers.map(column => (
               <th
                 {...column.getHeaderProps()}
                 style={{
                   borderBottom: 'solid 3px red',
                   background: 'aliceblue',
                   color: 'black',
                   fontWeight: 'bold',
                 }}
               >
                 {column.render('Header')}
               </th>
             ))}
           </tr>
         ))}
       </thead>
       <tbody {...getTableBodyProps()}>
         {rows.map(row => {
           prepareRow(row)
           return (
             <tr {...row.getRowProps()}>
               {row.cells.map(cell => {
                 return (
                   <td
                     {...cell.getCellProps()}
                     style={{
                       padding: '10px',
                       border: 'solid 1px gray',
                       background: 'papayawhip',
                     }}
                   >
                     {cell.render('Cell')}
                   </td>
                 )
               })}
             </tr>
           )
         })}
       </tbody>
      </table>
    </div>
  )
}

const useTableDataFetch = ({
  wbId,
  tableType,
}) => {
  const [data, setData] = useState([])
  const [error, setError] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadData(wbId, tableType).then((json) => {
      setData(json.data)
      setLoading(false)
    }).catch((error) => {
      setError(error)
      setLoading(false)
    })
  }, [wbId, tableType])

  return {
    data,
    error,
    loading,
  }
}

export const PhenotypeAbi1 = () => {
  const { data } = useTableDataFetch({
    wbId: 'WBGene00015146',
    tableType: 'phenotype_flat',
  })

  const columns = useMemo(() => ([
    {accessor: 'phenotype'},
    {accessor: 'entity'},
    {accessor: 'evidence'},
  ]), [])

  return (
    <GenericTestTable data={data} columns={columns} />
  )
}
