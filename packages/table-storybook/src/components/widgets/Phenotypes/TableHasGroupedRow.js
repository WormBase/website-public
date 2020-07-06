import React, { useMemo, useState } from 'react'
import {
  useAsyncDebounce,
  useBlockLayout,
  useFilters,
  useGlobalFilter,
  useGroupBy,
  useResizeColumns,
  useSortBy,
  useExpanded,
  usePagination,
  useTable,
} from 'react-table'
import CsvPheno from './CsvPheno'
import matchSorter from 'match-sorter'
import { makeStyles } from '@material-ui/core/styles'
import Checkbox from '@material-ui/core/Checkbox'
import ClickAwayListener from '@material-ui/core/ClickAwayListener'
import FormControl from '@material-ui/core/FormControl'
import FormControlLabel from '@material-ui/core/FormControlLabel'
import FormGroup from '@material-ui/core/FormGroup'
import FormLabel from '@material-ui/core/FormLabel'
import ArrowDownwardIcon from '@material-ui/icons/ArrowDownward'
import ArrowDropDownIcon from '@material-ui/icons/ArrowDropDown'
import ArrowUpwardIcon from '@material-ui/icons/ArrowUpward'
import ArrowRightIcon from '@material-ui/icons/ArrowRight'
import FilterListIcon from '@material-ui/icons/FilterList'

const useStyles = makeStyles({
  table: {
    color: '#444',
    borderSpacing: 0,
    border: '1px solid #ededed',
    '& thead': {
      backgroundColor: '#e9eef2',
    },
    '& thead input': {
      borderRadius: 5,
      border: '1px solid #ddd',
    },
    '& tr:last-child td': {
      borderBottom: 0,
    },
    '& th,td': {
      margin: 0,
      padding: '0.6rem 0.3rem',
      borderBottom: '1px solid #ededed',
      borderRight: '1px solid #ededed',
      position: 'relative',
    },
    '& td': {
      padding: '0.1rem 0.3rem',
    },
    '& th:last-child,td:last-child': {
      borderRight: 0,
    },
    '& tbody tr .is_grouped,tbody tr .is_aggregated': {
      backgroundColor: '#dedede',
      borderRight: 'none',
    },
    '& tbody tr .is_placeholder': {
      backgroundColor: '#d3d6ff',
    },
    '& tbody tr .is_other': {
      backgroundColor: '#e2e5ff',
    },
    '& th .resizer': {
      display: 'inline-block',
      width: 10,
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
    '& th .column_header': {
      textAlign: 'left',
    },
    '& th .sort-arrow-icon': {
      fontSize: '1rem',
      marginLeft: 5,
    },
  },
  pagination: {
    padding: '0.8rem 0.5rem',
    backgroundColor: '#e9eef2',
  },
  displayed_data_info: {
    textAlign: 'right',
    marginBottom: 5,
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'flex-end',
    '& span': {
      marginRight: 15,
    },
  },
  container: {
    display: 'inline-block',
  },
  column_filter_root: {
    position: 'relative',
  },
  column_filter_dropdown: {
    position: 'absolute',
    top: 28,
    left: 0,
    zIndex: 1,
    border: '1px solid',
    backgroundColor: 'white',
    padding: 5,
  },
  rows_count: {
    '& .row-arrow-icon': {
      fontSize: '1.5rem',
      marginRight: 10,
    },
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
      type='search'
      style={{
        fontSize: '1.1rem',
        marginBottom: 10,
        marginRight: 10,
        width: '90%',
      }}
    />
  )
}

const TableHasGroupedRow = ({ columns, data, WBid, tableType }) => {
  const classes = useStyles()

  const [displayFilter, setDisplayFilter] = useState({
    phentypeLabel: false,
    entity: false,
    evidence: false,
  })

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

  const storeFilterValOfAllele = (data, kArr) => {
    if (data?.Allele) {
      kArr.push(data.Allele.text.label)

      if (data.Allele.evidence?.Curator) {
        kArr.push(data.Allele.evidence.Curator[0].label)
      }
      if (data.Allele.evidence?.Paper_evidence) {
        kArr.push(data.Allele.evidence.Paper_evidence[0].label)
      }
      if (data.Allele.evidence?.Remark) {
        kArr.push(data.Allele.evidence.Remark[0])
      }
    }
  }

  const storeFilterValOfRNAi = (data, kArr) => {
    if (data?.RNAi) {
      kArr.push(data.RNAi.text.label)

      if (data.RNAi.evidence?.Genotype) {
        kArr.push(data.RNAi.evidence.Genotype)
      }
      if (data.RNAi.evidence?.Paper_evidence) {
        kArr.push(data.RNAi.evidence.Paper_evidence.label)
      }
      if (data.RNAi.evidence?.Remark) {
        kArr.push(data.RNAi.evidence.Remark[0])
      }
    }
  }

  const storeFilterValOfOverexpression = (data, kArr) => {
    kArr.push(data.text.label)

    if (data.evidence?.Curator) {
      kArr.push(data.evidence.Curator[0].label)
    }
    if (data.evidence?.Paper_evidence) {
      kArr.push(data.evidence.Paper_evidence[0].label)
    }
    if (data.evidence?.Remark) {
      kArr.push(data.evidence.Remark[0])
    }
    if (data.evidence?.Caused_by_gene) {
      kArr.push(data.evidence.Caused_by_gene[0].label)
    }
  }

  const storeFilterValOfEntity = (data, kArr) => {
    if (data) {
      const key = Object.keys(data)
      data[key].forEach((e) => {
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

          if (row.values[id]?.Transgene) {
            storeFilterValOfOverexpression(row.values[id].Transgene, keyArr)
          } else {
            storeFilterValOfAllele(row.values[id], keyArr)
            storeFilterValOfRNAi(row.values[id], keyArr)
          }

          return keyArr
        }

        return matchSorter(rows, filterValue, { keys: [(row) => keyFunc(row)] })
      },

      entitiesFilter: (rows, id, filterValue) => {
        const keyFunc = (row) => {
          let keyArr = []

          storeFilterValOfEntity(row.values[id], keyArr)

          return keyArr
        }

        return matchSorter(rows, filterValue, {
          keys: [(row) => keyFunc(row)],
        })
      },

      defaultGlobalFilter: (rows, id, filterValue) => {
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
          if (rowVals[id[2]]?.Transgene) {
            storeFilterValOfOverexpression(rowVals[id[2]].Transgene, keyArr)
          } else {
            storeFilterValOfAllele(rowVals[id[2]], keyArr)
            storeFilterValOfRNAi(rowVals[id[2]], keyArr)
          }

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
        type='search'
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

  const getDefaultExpandedRows = (data, threshold) => {
    const defaultExpandedRows = {}
    const defaultHidRows = {}

    data.forEach((d) => {
      const key = `phenotype.label:${d.phenotype.label}`
      if (defaultHidRows[key]) {
        defaultHidRows[key] = ++defaultHidRows[key]
      } else {
        defaultHidRows[key] = 1
      }
    })

    data.forEach((d) => {
      const key = `phenotype.label:${d.phenotype.label}`
      if (defaultHidRows[key] < threshold) {
        defaultExpandedRows[key] = true
      } else {
        defaultExpandedRows[key] = false
      }
    })

    return defaultExpandedRows
  }

  const displayFilterFn = (column) => {
    if (
      (column.id === 'phenotype.label' && displayFilter['phenotypeLabel']) ||
      (column.id === 'entity' && displayFilter['entity']) ||
      (column.id === 'evidence' && displayFilter['evidence'])
    ) {
      return column.render('Filter')
    }
    return null
  }

  const ClickAway = () => {
    const [open, setOpen] = useState(false)

    const handleClick = () => {
      setOpen((prev) => !prev)
    }
    const handleClickAway = () => {
      setOpen(false)
    }

    return (
      <ClickAwayListener onClickAway={handleClickAway}>
        <span className={classes.column_filter_root}>
          <button type='button' onClick={handleClick}>
            <FilterListIcon />
          </button>
          {open ? (
            <span className={classes.column_filter_dropdown}>
              <CheckboxesGroup />
            </span>
          ) : null}
        </span>
      </ClickAwayListener>
    )
  }

  const CheckboxesGroup = () => {
    const handleChange = (event) => {
      setDisplayFilter({
        ...displayFilter,
        [event.target.name]: event.target.checked,
      })
    }
    const { phenotypeLabel, entity, evidence } = displayFilter

    return (
      <FormControl component='fieldset'>
        <FormLabel component='legend'>Column search</FormLabel>
        <FormGroup>
          <FormControlLabel
            control={
              <Checkbox
                checked={phenotypeLabel}
                onChange={handleChange}
                name='phenotypeLabel'
              />
            }
            label='Phenotype'
          />
          <FormControlLabel
            control={
              <Checkbox
                checked={entity}
                onChange={handleChange}
                name='entity'
              />
            }
            label='Entities Affected'
          />
          <FormControlLabel
            control={
              <Checkbox
                checked={evidence}
                onChange={handleChange}
                name='evidence'
              />
            }
            label='Supported Evidence'
          />
        </FormGroup>
      </FormControl>
    )
  }

  const enableToggleRowExpand = (row, cell) => {
    if (cell.isGrouped || cell.isAggregated) {
      return cell.getCellProps(row.getToggleRowExpandedProps())
    }
    return cell.getCellProps()
  }

  const displayHiddenRowsCount = (cell, row) => {
    if (cell.column.id === 'evidence' && row.subRows.length >= 10) {
      return (
        <>
          {cell.render('Aggregated')}
          <span className={classes.rows_count}>
            {row.isExpanded ? (
              <ArrowDropDownIcon className='row-arrow-icon' />
            ) : (
              <ArrowRightIcon className='row-arrow-icon' />
            )}
          </span>
          {row.subRows.length} Results
        </>
      )
    }
    return cell.render('Aggregated')
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
      disableSortRemove: true,
      filterTypes,
      defaultColumn,
      globalFilter: 'defaultGlobalFilter',
      // initialState: { pageIndex: 0 },
      paginateExpandedRows: false,
      initialState: {
        pageIndex: 0,
        pageSize: 10,
        sortBy: [{ id: 'phenotype.label', desc: false }],
        groupBy: ['phenotype.label'],
        expanded: getDefaultExpandedRows(data, 10),
      },
    },
    useBlockLayout,
    useFilters,
    useGlobalFilter,
    useResizeColumns,
    useGroupBy,
    useSortBy,
    useExpanded,
    usePagination
  )

  return (
    <div className={classes.container}>
      <span className={classes.displayed_data_info}>
        <span>{rows.length} entries</span>
        <CsvPheno data={data} WBid={WBid} tableType={tableType} />
      </span>
      <table {...getTableProps()} className={classes.table}>
        <thead>
          <tr>
            <th>
              <GlobalFilter
                globalFilter={globalFilter}
                setGlobalFilter={setGlobalFilter}
              />
              <ClickAway />
            </th>
          </tr>
          {headerGroups.map((headerGroup) => (
            <tr {...headerGroup.getHeaderGroupProps()}>
              {headerGroup.headers.map((column) => (
                <th {...column.getHeaderProps()}>
                  <div
                    {...column.getSortByToggleProps()}
                    className='column_header'
                  >
                    {column.render('Header')}
                    {column.canSort ? (
                      column.isSorted ? (
                        column.isSortedDesc ? (
                          <ArrowDownwardIcon className='sort-arrow-icon' />
                        ) : (
                          <ArrowUpwardIcon className='sort-arrow-icon' />
                        )
                      ) : (
                        ''
                      )
                    ) : (
                      ''
                    )}
                  </div>
                  <div className='filter'>
                    {column.canFilter ? displayFilterFn(column) : null}
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
                  return (
                    <td
                      {...enableToggleRowExpand(row, cell)}
                      className={
                        cell.isGrouped
                          ? 'is_grouped'
                          : cell.isAggregated
                          ? 'is_aggregated'
                          : cell.isPlaceholder
                          ? 'is_placeholder'
                          : 'is_other'
                      }
                    >
                      <div>
                        {cell.isGrouped ? (
                          <div>{cell.render('Cell')}</div>
                        ) : cell.isAggregated ? (
                          <div>{displayHiddenRowsCount(cell, row)}</div>
                        ) : cell.isPlaceholder ? null : (
                          <div>{cell.render('Cell')}</div>
                        )}
                      </div>
                    </td>
                  )
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
          {[5, 10, 25, 100, 500].map((pageSize) => (
            <option key={pageSize} value={pageSize}>
              Show {pageSize}
            </option>
          ))}
        </select>
      </div>
    </div>
  )
}

export default TableHasGroupedRow
