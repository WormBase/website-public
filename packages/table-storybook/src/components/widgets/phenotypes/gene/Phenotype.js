import React, { useState, useEffect, useMemo } from 'react'
import {
  useTable,
  useFilters,
  useSortBy,
  useBlockLayout,
  useResizeColumns,
} from 'react-table'
import { makeStyles } from '@material-ui/core/styles'
import Allele from './Allele'

const Phenotype = () => {
  const useStyles = makeStyles({
    table: {
      borderSpacing: 0,
      border: '1px solid #ededed',
      '& thead': {
        backgroundColor: '#e9eef2',
      },
      '& tr:last-child td': {
        borderBottom: 0,
      },
      '& th,td': {
        margin: 0,
        padding: '0.5rem',
        borderBottom: '1px solid #ededed',
        borderRight: '1px solid #ededed',
        position: 'relative',
      },
      '& th:last-child,td:last-child': {
        borderRight: 0,
      },
      '& tr:nth-child(even)': {
        backgroundColor: '#e2e5ff',
      },
      'th::before': {
        position: 'absolute',
        right: '15px',
        top: '16px',
        content: '',
        width: 0,
        height: 0,
        borderLeft: '5px solid transparent',
        borderRight: '5px solid transparent',
      },
      '& th .resizer': {
        display: 'inline-block',
        width: '10px',
        height: '100%',
        position: 'absolute',
        right: 0,
        top: 0,
        transform: 'translateX(50%)',
        zIndex: 1,
        touchAction: 'none',
      },
      '& th .isResizing': {
        background: '#828A95',
      },
      '& th .filter input': {
        width: '80%',
      },
    },
  })

  const classes = useStyles()

  const [data, setData] = useState([])

  const proxyUrl = 'https://calm-reaches-60051.herokuapp.com/'
  const targetUrl =
    'http://rest.wormbase.org/rest/field/gene/WBGene00000904/phenotype'

  useEffect(() => {
    loadData()
  }, [])

  const loadData = async () => {
    const res = await fetch(proxyUrl + targetUrl)
    const json = await res.json()
    console.log(json.phenotype.data)
    setData(json.phenotype.data)
  }

  const defaultColumn = useMemo(
    () => ({
      minWidth: 120,
      width: 180,
      maxWidth: 600,
    }),
    []
  )

  const defaultColumnFilter = ({
    column: { filterValue, preFilteredRows, setFilter },
  }) => {
    const count = preFilteredRows.length

    return (
      <input
        value={filterValue || ''}
        onChange={(e) => {
          setFilter(e.target.value || undefined)
        }}
        placeholder={`Search ${count} records...`}
      />
    )
  }

  const filterTypes = useMemo(
    () => ({
      text: (rows, id, filterValue) => {
        return rows.filter((row) => {
          const rowValue = row.values[id]
          return rowValue !== undefined
            ? String(rowValue)
                .toLowerCase()
                .startsWith(String(filterValue).toLowerCase())
            : true
        })
      },
    }),
    []
  )

  const columns = useMemo(
    () => [
      {
        Header: 'Phenotype',
        accessor: 'phenotype.label',
        Filter: defaultColumnFilter,
      },
      {
        Header: 'Entities Affected',
        accessor: 'entity',
        Cell: ({ cell: { value } }) => (value === null ? 'N/A' : value),
        disableFilters: true,
      },
      {
        Header: 'Supporting Evidence',
        accessor: 'evidence.Allele',
        Cell: ({ cell: { value } }) => <Allele values={value} />,
        disableFilters: true,
        minWidth: 240,
        width: 540,
      },
    ],
    []
  )

  const {
    getTableProps,
    getTableBodyProps,
    headerGroups,
    rows,
    prepareRow,
  } = useTable(
    { columns, data, filterTypes, defaultColumn },
    useBlockLayout,
    useFilters,
    useResizeColumns,
    useSortBy
  )

  return (
    <div>
      <table {...getTableProps()} className={classes.table}>
        <thead>
          {headerGroups.map((headerGroup) => (
            <tr {...headerGroup.getHeaderGroupProps()}>
              {headerGroup.headers.map((column) => (
                <th {...column.getHeaderProps()}>
                  <span {...column.getSortByToggleProps()}>
                    {column.render('Header')}
                    {column.isSorted
                      ? column.isSortedDesc
                        ? ' 🔽'
                        : ' 🔼'
                      : ''}
                  </span>
                  <div className='filter'>
                    {column.canFilter ? column.render('Filter') : null}
                  </div>
                  <div
                    {...column.getResizerProps()}
                    className={`resizer ${
                      column.isResizing ? 'isResizing' : ''
                    }`}
                  />
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody {...getTableBodyProps()}>
          {rows.map((row) => {
            prepareRow(row)
            return (
              <tr {...row.getRowProps()}>
                {row.cells.map((cell) => {
                  console.log(cell.render('Cell'))
                  return <td {...cell.getCellProps()}>{cell.render('Cell')}</td>
                })}
              </tr>
            )
          })}
        </tbody>
      </table>
    </div>
  )
}

export default Phenotype
