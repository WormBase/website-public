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
  data = [],
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
  defaultValue = [],
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

const LoadDataProgress = ({children, ...useTableDataFetchOptions}) => {
  const state = useTableDataFetch(useTableDataFetchOptions)
  const { loading, error } = state
  return (
    loading ? 'Loading data from the server...' :
    error ? <span style={{color: 'tomato'}}> Error occured loading data</span> :
    children(state)
  )
}

export const PhenotypeAbi1 = () => {
  const columns = useMemo(() => ([
    {accessor: 'phenotype'},
    {accessor: 'entity'},
    {accessor: 'evidence'},
  ]), [])

  return (
    <LoadDataProgress wbId="WBGene00015146" tableType="phenotype_flat">
      {({data}) => <GenericTestTable data={data} columns={columns} />}
    </LoadDataProgress>
  )
}

export const PhenotypeByInteractionAbi1 = () => {

  const columns = useMemo(() => ([
    {accessor: 'phenotype'},
    {accessor: 'interactions'},
    {accessor: 'interaction_type'},
    {accessor: 'citations'},
  ]), [])

  return (
    <LoadDataProgress wbId="WBGene00015146" tableType="phenotype_by_interaction">
      {({data}) => <GenericTestTable data={data} columns={columns} />}
    </LoadDataProgress>
  )
}

export const BestBlastpMatchesAbi1 = () => {

  const columns = useMemo(() => ([
    {accessor: 'evalue'},
    {accessor: 'taxonomy'},
    {accessor: 'hit'},
    {accessor: 'description'},
    {accessor: 'percent'},
  ]), [])

  return (
    <LoadDataProgress wbId="WBGene00015146" tableType="best_blastp_matches">
      {({data}) => <GenericTestTable data={data.hits} columns={columns} />}
    </LoadDataProgress>
  )
}

export const InteractionsAbi1 = () => {
  const columns = useMemo(() => ([
    {accessor: 'interactions'},
    {accessor: 'type'},
    {accessor: 'effector'},
    {accessor: 'affected'},
    {accessor: 'direction'},
    {accessor: 'citations'},
  ]), [])

  return (
    <LoadDataProgress wbId="WBGene00015146" tableType="interactions">
      {({data}) => <GenericTestTable data={data.edges} columns={columns} />}
    </LoadDataProgress>
  )
}

export const InteractionsDaf2 = () => {
  const columns = useMemo(() => ([
    {accessor: 'interactions'},
    {accessor: 'type'},
    {accessor: 'effector'},
    {accessor: 'affected'},
    {accessor: 'direction'},
    {accessor: 'citations'},
  ]), [])

  return (
    <LoadDataProgress wbId="WBGene00000898" tableType="interactions">
      {({data}) => <GenericTestTable data={data.edges} columns={columns} />}
    </LoadDataProgress>
  )
}
