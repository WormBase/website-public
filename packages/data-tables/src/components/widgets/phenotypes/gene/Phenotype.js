import React, { useState, useEffect, useMemo } from 'react'
import { useTable, useFilters, useSortBy } from 'react-table'
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

  const DefaultColumnFilter = ({
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
        Filter: DefaultColumnFilter,
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
  } = useTable({ columns, data, filterTypes }, useFilters, useSortBy)

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
                  <div>{column.canFilter ? column.render('Filter') : null}</div>
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
