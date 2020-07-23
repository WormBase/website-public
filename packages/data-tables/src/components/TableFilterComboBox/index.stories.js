import React, { useState, useEffect, useMemo, useCallback } from 'react'
import get from 'lodash/get'
import TableFilterComboBox from './index';
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

function flattenRecursive(data, prefix = [], result = {}) {
  if (Object(data) !== data) {
    if (data) {
      result[prefix.join('.')] = data
    }
    return result
  } else {
    Object.keys(data).forEach((key) => {
      flattenRecursive(data[key], [...prefix, key], result)
    })
    return result
  }
}

const CellDefault = ({value}) => <pre>{JSON.stringify(flattenRecursive(value), null, 2)}</pre>

export const Phenotype = () => {
  const [data, setData] = useState([])
  const wbId = 'WBGene00015146'
  const tableType = 'phenotype_flat'

  useEffect(() => {
    loadData(wbId, tableType).then((json) => {
      setData(json.data)
    })
  }, [wbId, tableType])

  const options = useMemo(() => {
    return data.reduce((result, item) => {
      const itemflat = flattenRecursive(item)
      Object.keys(itemflat).forEach((key, i) => {
        if (!result[key]) {
          result[key] = ['(Empty)']
        }
        if (result[key].indexOf(itemflat[key]) === -1) {
          result[key].push(itemflat[key])
        }
      })
      return result;
    }, {})
  }, [data])

  const columns = useMemo(() => ([
    {accessor: 'phenotype', Header: 'phenotype', Cell: CellDefault},
    {accessor: 'entity', Header: 'entity', Cell: CellDefault},
    {accessor: 'evidence', Header: 'evidence', Cell: CellDefault},
  ]), [])

  const [filters, setFilters] = useState([])

  const filterTypes = React.useMemo(
    () => ({
      testGlobalFilter: (rows,b,c) => {
        // const filters = [
        //   {
        //     key: 'evidence.RNAi.text.id',
        //     value: 'WBRNAi00073492',
        //   },
        //   {
        //     key: 'phenotype.id',
        //     value: 'WBPhenotype:0000688',
        //   },
        // ]
        return rows.filter(({values}) => {
          return filters.reduce((isMatchSoFar, { key, value: filterValue }) => {
            return isMatchSoFar && (get(values, key.split('.')) === filterValue)
          }, true)
        });
      }
    }),
    [filters]
  )

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
  } = useTable({
    columns,
    data,
    filterTypes,
    globalFilter: 'testGlobalFilter',
    initialState: {
      globalFilter: 'testGlobalFilter',
    },
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
