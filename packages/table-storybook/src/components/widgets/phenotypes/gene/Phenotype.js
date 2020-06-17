import React, { useState, useEffect, useMemo } from 'react'
import {
  useTable,
  useFilters,
  useGlobalFilter,
  useAsyncDebounce,
  useSortBy,
  useBlockLayout,
  useResizeColumns,
  usePagination,
} from 'react-table'
import { makeStyles } from '@material-ui/core/styles'
import matchSorter from 'match-sorter'
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

  const GlobalFilter = ({ globalFilter, setGlobalFilter }) => {
    const [value, setValue] = useState(globalFilter)
    const onChange = useAsyncDebounce((value) => {
      setGlobalFilter(value || undefined)
    }, 1000)

    return (
      <input
        value={value || ''}
        onChange={(e) => {
          setValue(e.target.value)
          onChange(e.target.value)
        }}
        placeholder={`Search all columns`}
        style={{
          fontSize: '1.2rem',
          marginBottom: '10px',
          width: '90%',
        }}
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

  const filterTypes = useMemo(
    () => ({
      evidenceFilter: (rows, id, filterValue) => {
        const keyFunc = (row) => {
          let keyArr = []
          if (row.values[id]?.Allele) {
            const alleleValue = row.values[id].Allele.map((a) => a.text.label)
            keyArr.push(...alleleValue)
          }
          if (row.values[id]?.RNAi) {
            const rnaiValue = row.values[id].RNAi.map((r) => r.text.label)
            keyArr.push(...rnaiValue)
          }
          // For drives_overexpression table
          if (!row.values[id]?.Allele && !row.values[id]?.RNAi) {
            const overExpressionValue = row.values[id].map((o) => o.text.label)
            keyArr.push(...overExpressionValue)
          }

          return keyArr
        }
        return matchSorter(rows, filterValue, { keys: [(row) => keyFunc(row)] })
      },
      defaultGlobalFilter: (rows, id, filterValue) => {
        /*
        id[0] is "phenotype.label",
        id[1] is "entity",
        id[2] is "evidence"
        */
        const keyFunc = (row) => {
          let keyArr = []
          keyArr.push(row.values[id[0]])

          if (row.values[id[1]] !== null) {
            const entityValue = row.values[id[1]].map((e) => [
              e.pato_evidence.entity_term.label,
              e.pato_evidence.entity_term,
            ])
            keyArr.push(entityValue.flat())
          }

          if (row.values[id[2]]?.Allele) {
            for (const a of row.values[id[2]].Allele) {
              keyArr.push(a.text.label)

              if (a.evidence?.Curator) {
                keyArr.push(a.evidence.Curator[0].label)
              }
              if (a.evidence?.Paper_evidence) {
                keyArr.push(a.evidence.Paper_evidence[0].label)
              }
              if (a.evidence?.Remark) {
                keyArr.push(a.evidence.Remark[0])
              }
            }
          }
          if (row.values[id[2]]?.RNAi) {
            for (const r of row.values[id[2]].RNAi) {
              keyArr.push(r.text.label)

              if (r.evidence?.Genotype) {
                keyArr.push(r.evidence.Genotype)
              }
              if (r.evidence?.paper) {
                keyArr.push(r.evidence.paper.label)
              }
              if (r.evidence?.Remark) {
                keyArr.push(r.evidence.Remark[0])
              }
            }
          }

          // For drives_overexpression table
          if (!row.values[id[2]]?.Allele && !row.values[id[2]]?.RNAi) {
            const overExpressionValue = row.values[id[2]].map((o) => [
              o.text.label,
              o.evidence?.Curator[0].label,
              o.evidence?.Paper_evidence[0].label,
              o.evidence?.Remark[0],
            ])
            keyArr.push(...overExpressionValue)
          }

          return keyArr
        }
        return matchSorter(rows, filterValue, { keys: [(row) => keyFunc(row)] })
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
        disableSortBy: true,
        filter: 'evidenceFilter',
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
    setGlobalFilter,
    state: { pageIndex, pageSize, globalFilter },
  } = useTable(
    {
      columns,
      data,
      sortTypes,
      filterTypes,
      defaultColumn,
      initialState: { pageIndex: 0 },
      globalFilter: 'defaultGlobalFilter',
    },
    useBlockLayout,
    useFilters,
    useGlobalFilter,
    useResizeColumns,
    useSortBy,
    usePagination
  )

  return (
    <div>
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
