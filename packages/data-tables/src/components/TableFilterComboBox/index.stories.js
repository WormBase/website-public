import React, { useState, useEffect, useMemo, useCallback } from 'react'
import TableFilterComboBox from './index';
import { useWormBaseTableFilter } from './useWormBaseTableFilter'
import { useTable, useFilters, useGlobalFilter } from 'react-table'
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

export const Phenotype = () => {
  const [data, setData] = useState([])
  const wbId = 'WBGene00015146'
  const tableType = 'phenotype_flat'

  useEffect(() => {
    loadData(wbId, tableType).then((json) => {
      setData(json.data)
    })
  }, [wbId, tableType])

  const {
    filters,
    setFilters,
    options,
    tableOptions,
  } = useWormBaseTableFilter(data);

  const columns = useMemo(() => ([
    {accessor: 'phenotype', Header: 'phenotype', Cell: CellDefault},
    {accessor: 'entity', Header: 'entity', Cell: CellDefault},
    {accessor: 'evidence', Header: 'evidence', Cell: CellDefault},
  ]), [])

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
