import React, { useMemo, useState } from 'react'
import {
  useAsyncDebounce,
  useBlockLayout,
  useFilters,
  useGlobalFilter,
  usePagination,
  useResizeColumns,
  useSortBy,
  useTable,
} from 'react-table'
import { makeStyles } from '@material-ui/core/styles'
import matchSorter from 'match-sorter'

const useStyles = makeStyles({
  table: {
    borderSpacing: 0,
    border: '1px solid #ededed',
    '& thead': {
      backgroundColor: '#e9eef2',
    },
    '& thead input': {
      borderRadius: '5px',
      border: '1px solid #ddd',
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
    '& tbody tr:nth-child(even)': {
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
    '& th .sortable::before, th .sort-asc::before, th .sort-desc::before': {
      position: 'absolute',
      right: '22px',
      content: '""',
      width: 0,
      height: 0,
      borderLeft: '5px solid transparent',
      borderRight: '5px solid transparent',
      borderTop: '5px solid gray',
      top: '23px',
    },
    '& th .sortable::after, th .sort-asc::after, th .sort-desc::after': {
      position: 'absolute',
      right: '22px',
      content: '""',
      width: 0,
      height: 0,
      borderLeft: '5px solid transparent',
      borderRight: '5px solid transparent',
      borderBottom: '5px solid gray',
      top: '16px',
    },
    '& th .sort-asc::before': {
      borderTop: 'none',
    },
    '& th .sort-asc::after': {
      borderBottom: '5px solid black',
    },
    '& th .sort-desc::before': {
      borderTop: '5px solid black',
      top: '23px',
    },
    '& th .sort-desc::after': {
      borderBottom: 'none',
    },
  },
  pagination: {
    padding: '0.5rem',
  },
  displayed_data_info: {
    textAlign: 'right',
    marginBottom: '5px',
  },
  container: {
    display: 'inline-block',
  },
})

const GlobalFilter = ({ globalFilter, setGlobalFilter }) => {
  const [value, setValue] = useState(globalFilter)
  const onChange = useAsyncDebounce((value) => {
    setGlobalFilter(value || undefined)
  }, 200)

  return (
    <input
      value={value || ''}
      onChange={(e) => {
        setValue(e.target.value)
        onChange(e.target.value)
      }}
      placeholder={`Search all columns...`}
      style={{
        fontSize: '1.1rem',
        marginBottom: '10px',
        width: '90%',
      }}
    />
  )
}

const Table = ({ columns, data, tableType }) => {
  console.log(data)
  const classes = useStyles()

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

  const storeFilterValOfAllele = (data, kArr) => {
    if (data?.Allele) {
      data.Allele.forEach((a) => {
        kArr.push(a.text.label)
        if (a.evidence?.Curator) {
          kArr.push(a.evidence.Curator[0].label)
        }
        if (a.evidence?.Paper_evidence) {
          kArr.push(a.evidence.Paper_evidence[0].label)
        }
        if (a.evidence?.Remark) {
          kArr.push(a.evidence.Remark[0])
        }
      })
    }
  }

  const storeFilterValOfRNAi = (data, kArr) => {
    if (data?.RNAi) {
      data.RNAi.forEach((r) => {
        kArr.push(r.text.label)
        if (r.evidence?.Genotype) {
          kArr.push(r.evidence.Genotype)
        }
        if (r.evidence?.Paper_evidence) {
          kArr.push(r.evidence.Paper_evidence[0].label)
        }
        if (r.evidence?.Remark) {
          kArr.push(r.evidence.Remark[0])
        }
      })
    }
  }

  const storeFilterValOfEntity = (data, kArr) => {
    if (data) {
      data.forEach((e) => {
        kArr.push(
          ...[
            e.pato_evidence.entity_type,
            e.pato_evidence.entity_term.label,
            e.pato_evidence.pato_term,
          ]
        )
      })
    } else {
      kArr.push('N/A')
    }
  }

  const filterTypes = useMemo(
    () => ({
      evidenceFilter: (rows, id, filterValue) => {
        const keyFunc = (row) => {
          let keyArr = []

          storeFilterValOfAllele(row.values.evidence, keyArr)
          storeFilterValOfRNAi(row.values.evidence, keyArr)

          return keyArr
        }

        return matchSorter(rows, filterValue, { keys: [(row) => keyFunc(row)] })
      },

      entitiesFilter: (rows, id, filterValue) => {
        const keyFunc = (row) => {
          let keyArr = []

          storeFilterValOfEntity(row.values.entity, keyArr)

          return keyArr
        }

        return matchSorter(rows, filterValue, {
          keys: [(row) => keyFunc(row)],
        })
      },

      globalFilterForTableGroup1: (rows, id, filterValue) => {
        const keyFunc = (row) => {
          /*
          id[0] is "phenotype.label",
          id[1] is "entity",
          id[2] is "evidence"
          */

          let keyArr = []
          const rowVals = row.values
          keyArr.push(rowVals[id[0]])

          storeFilterValOfEntity(rowVals[id[1]], keyArr)
          storeFilterValOfAllele(rowVals[id[2]], keyArr)
          storeFilterValOfRNAi(rowVals[id[2]], keyArr)

          // For drives_overexpression table
          if (!rowVals[id[2]]?.Allele && !rowVals[id[2]]?.RNAi) {
            for (const o of rowVals[id[2]]) {
              keyArr.push(o.text.label)

              if (o.evidence?.Curator) {
                keyArr.push(o.evidence.Curator[0].label)
              }
              if (o.evidence?.Paper_evidence) {
                keyArr.push(o.evidence?.Paper_evidence[0].label)
              }
              if (o.evidence?.Remark) {
                keyArr.push(o.evidence.Remark[0])
              }
            }
          }

          return keyArr
        }

        return matchSorter(rows, filterValue, { keys: [(row) => keyFunc(row)] })
      },

      globalFilterForTableGroup2: (rows, id, filterValue) => {
        /*
        id[0] is "phenotype.label",
        id[1] is "interactions",
        id[2] is "interactions_type",
        id[3] is "citations"
        */
        const keyFunc = (row) => {
          let keyArr = []
          keyArr.push(row.values[id[0]])

          const interactionsValue = row.values[id[1]].map((i) => i.label)
          keyArr.push(...interactionsValue)

          keyArr.push(row.values[id[2]])

          const citationsValue = row.values[id[3]].map((c) => c?.label)
          keyArr.push(...citationsValue)

          return keyArr
        }
        return matchSorter(rows, filterValue, { keys: [(row) => keyFunc(row)] })
      },
    }),
    []
  )

  const defaultColumnFilter = ({ column: { filterValue, setFilter } }) => {
    return (
      <input
        value={filterValue || ''}
        onChange={(e) => {
          setFilter(e.target.value || undefined)
        }}
        placeholder={`Search...`}
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

  const selectGlobalFilter = (tableType) => {
    const tableGroup1 = [
      'phenotype',
      'phenotype_not_observed',
      'drives_overexpression',
    ]
    const tableGroup2 = ['phenotype_by_interaction']

    if (tableGroup1.includes(tableType)) {
      return 'globalFilterForTableGroup1'
    }
    if (tableGroup2.includes(tableType)) {
      return 'globalFilterForTableGroup2'
    } else {
      console.error(tableType)
      return null
    }
  }

  const {
    getTableProps,
    getTableBodyProps,
    prepareRow,
    headerGroups,
    page,
    rows,
    canPreviousPage,
    canNextPage,
    pageOptions,
    pageCount,
    gotoPage,
    nextPage,
    previousPage,
    setPageSize,
    setGlobalFilter,
    state: { pageIndex, pageSize, globalFilter },
  } = useTable(
    {
      columns,
      data,
      sortTypes,
      filterTypes,
      defaultColumn,
      globalFilter: selectGlobalFilter(tableType),
      initialState: { pageIndex: 0 },
    },
    useBlockLayout,
    useFilters,
    useGlobalFilter,
    useResizeColumns,
    useSortBy,
    usePagination
  )

  return (
    <div className={classes.container}>
      <div className={classes.displayed_data_info}>
        <b>{rows.length}</b> data displayed
      </div>
      <table {...getTableProps()} className={classes.table}>
        <thead>
          <tr>
            <th>
              <GlobalFilter
                globalFilter={globalFilter}
                setGlobalFilter={setGlobalFilter}
              />
            </th>
          </tr>
          {headerGroups.map((headerGroup) => (
            <tr {...headerGroup.getHeaderGroupProps()}>
              {headerGroup.headers.map((column) => (
                <th {...column.getHeaderProps()}>
                  <div
                    {...column.getSortByToggleProps()}
                    className={
                      column.canSort
                        ? column.isSorted
                          ? column.isSortedDesc
                            ? 'sort-desc'
                            : 'sort-asc'
                          : 'sortable'
                        : ''
                    }
                  >
                    {column.render('Header')}
                  </div>
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

export default Table
