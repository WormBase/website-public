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
import Allele from './Allele'
import RNAi from './RNAi'
import Entity from './Entity'
import Overexpression from './Overexpression'
import loadData from '../../../../services/loadData'

const Phenotype = ({ WBid, tableType }) => {
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
      sortType: 'alphanumeric', // Default. Used builtin 'alphanumeric' sortType.
      Filter: defaultColumnFilter,
      minWidth: 120,
      width: 180,
      maxWidth: 600,
    }),
    []
  )

  const sortTypes = useMemo(
    () => ({
      sortByEntity: (rowA, rowB) => {
        const entityOfRowA = rowA.values.entity
        const entityOfRowB = rowB.values.entity

        const comparisonStandardOfRowA =
          entityOfRowA === null
            ? 'n/a'
            : (
                entityOfRowA[0].pato_evidence.entity_type +
                entityOfRowA[0].pato_evidence.entity_term.label
              ).toLowerCase()
        const comparisonStandardOfRowB =
          entityOfRowB === null
            ? 'n/a'
            : (
                entityOfRowB[0].pato_evidence.entity_type +
                entityOfRowB[0].pato_evidence.entity_term.label
              ).toLowerCase()

        return comparisonStandardOfRowA > comparisonStandardOfRowB
          ? 1
          : comparisonStandardOfRowA < comparisonStandardOfRowB
          ? -1
          : 0
      },
    }),
    []
  )

  const showEntities = (value) => {
    if (value === null) {
      return 'N/A'
    } else {
      return <Entity values={value} />
    }
  }

  const showEvidence = (value) => {
    if (value.Allele && value.RNAi) {
      return (
        <>
          <div
            style={{
              marginBottom: '20px',
            }}
          >
            <Allele values={value.Allele} />
          </div>
          <RNAi values={value.RNAi} />
        </>
      )
    } else if (value.Allele) {
      return <Allele values={value.Allele} />
    } else if (value.RNAi) {
      return <RNAi values={value.RNAi} />
    } else {
      return <Overexpression values={value} />
    }
  }

  const columns = useMemo(
    () => [
      {
        Header: 'Phenotype',
        accessor: 'phenotype.label',
      },
      {
        Header: 'Entities Affected',
        accessor: 'entity',
        Cell: ({ cell: { value } }) => showEntities(value),
        disableFilters: true,
        sortType: 'sortByEntity',
      },
      {
        Header: 'Supporting Evidence',
        accessor: 'evidence',
        Cell: ({ cell: { value } }) => showEvidence(value),
        disableFilters: true,
        disableSortBy: true,
        minWidth: 240,
        width: 540,
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
      initialState: { pageIndex: 0 },
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

export default Phenotype
