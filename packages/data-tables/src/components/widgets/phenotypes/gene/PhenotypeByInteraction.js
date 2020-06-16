import React, { useState, useEffect, useMemo } from 'react'
import {
  useTable,
  useFilters,
  useSortBy,
  useBlockLayout,
  useResizeColumns,
  usePagination,
} from 'react-table'
import { makeStyles } from '@material-ui/core/styles'
import loadData from '../../../../services/loadData'

const PhenotypeByInteraction = ({ WBid, tableType }) => {
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
    pagination: {
      padding: '0.5rem',
    },
  })

  const classes = useStyles()

  const [data, setData] = useState([])

  useEffect(() => {
    loadData(WBid, tableType).then((json) => setData(json.data))
  }, [WBid, tableType])

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

  const defaultColumn = useMemo(
    () => ({
      filter: 'text', // Default. Used builtin 'text' filter.
      sortType: 'caseInsensitiveAlphaNumeric',
      Filter: defaultColumnFilter,
      minWidth: 120,
      width: 180,
      maxWidth: 600,
    }),
    []
  )

  const sortTypes = useMemo(
    () => ({
      caseInsensitiveAlphaNumeric: (rowA, rowB, columnId) => {
        const getRowValueByColumnID = (row, columnId) => row.values[columnId]
        const toString = (a) => {
          if (typeof a === 'number') {
            if (isNaN(a) || a === Infinity || a === -Infinity) {
              return ''
            }
            return String(a)
          }
          if (typeof a === 'string') {
            return a
          }
          return ''
        }
        const reSplitAlphaNumeric = /([0-9]+)/gm

        let a = getRowValueByColumnID(rowA, columnId)
        let b = getRowValueByColumnID(rowB, columnId)
        // Force to strings (or "" for unsupported types)
        // And lowercase to accomplish insensitive sort
        a = toString(a).toLowerCase()
        b = toString(b).toLowerCase()

        // Split on number groups, but keep the delimiter
        // Then remove falsey split values
        a = a.split(reSplitAlphaNumeric).filter(Boolean)
        b = b.split(reSplitAlphaNumeric).filter(Boolean)

        // While
        while (a.length && b.length) {
          let aa = a.shift()
          let bb = b.shift()

          const an = parseInt(aa, 10)
          const bn = parseInt(bb, 10)

          const combo = [an, bn].sort()

          // Both are string
          if (isNaN(combo[0])) {
            if (aa > bb) {
              return 1
            }
            if (bb > aa) {
              return -1
            }
            continue
          }

          // One is a string, one is a number
          if (isNaN(combo[1])) {
            return isNaN(an) ? -1 : 1
          }

          // Both are numbers
          if (an > bn) {
            return 1
          }
          if (bn > an) {
            return -1
          }
        }

        return a.length - b.length
      },
    }),
    []
  )

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

  const columns = useMemo(
    () => [
      {
        Header: 'Phenotype',
        accessor: 'phenotype.label',
      },
      {
        Header: 'Interactions',
        accessor: 'interactions',
        Cell: ({ cell: { value } }) => showInteractions(value),
        disableFilters: true,
        disableSortBy: true,
      },
      {
        Header: 'Interaction Type',
        accessor: 'interaction_type',
      },
      {
        Header: 'Citations',
        accessor: 'citations',
        Cell: ({ cell: { value } }) => showCitations(value),
        disableFilters: true,
        disableSortBy: true,
        minWidth: 240,
        width: 360,
      },
    ],
    []
  )

  const {
    getTableProps,
    getTableBodyProps,
    prepareRow,
    headerGroups,
    page,
    canPreviousPage,
    canNextPage,
    pageOptions,
    pageCount,
    gotoPage,
    nextPage,
    previousPage,
    setPageSize,
    state: { pageIndex, pageSize },
  } = useTable(
    {
      columns,
      data,
      sortTypes,
      defaultColumn,
      // initialState: { pageIndex: 0 },
      initialState: { pageIndex: 0, pageSize: 100 },
    },
    useBlockLayout,
    useFilters,
    useResizeColumns,
    useSortBy,
    usePagination
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
          {page.map((row) => {
            prepareRow(row)
            return (
              <tr {...row.getRowProps()}>
                {row.cells.map((cell) => {
                  return <td {...cell.getCellProps()}>{cell.render('Cell')}</td>
                })}
              </tr>
            )
          })}
        </tbody>
      </table>
      <div className={classes.pagination}>
        <button onClick={() => gotoPage(0)} disabled={!canPreviousPage}>
          {'<<'}
        </button>{' '}
        <button onClick={() => previousPage()} disabled={!canPreviousPage}>
          {'<'}
        </button>{' '}
        <button onClick={() => nextPage()} disabled={!canNextPage}>
          {'>'}
        </button>{' '}
        <button onClick={() => gotoPage(pageCount - 1)} disabled={!canNextPage}>
          {'>>'}
        </button>{' '}
        <span>
          Page{' '}
          <strong>
            {pageIndex + 1} of {pageOptions.length}
          </strong>{' '}
        </span>
        <select
          value={pageSize}
          onChange={(e) => {
            setPageSize(Number(e.target.value))
          }}
        >
          {[3, 10, 20, 100].map((pageSize) => (
            <option key={pageSize} value={pageSize}>
              Show {pageSize}
            </option>
          ))}
        </select>
      </div>
    </div>
  )
}

export default PhenotypeByInteraction
