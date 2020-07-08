import React, { useMemo, useState } from 'react'
import {
  useAsyncDebounce,
  useBlockLayout,
  useFilters,
  useGlobalFilter,
  useResizeColumns,
  useSortBy,
  useExpanded,
  usePagination,
  useTable,
} from 'react-table'
import matchSorter from 'match-sorter'
import { makeStyles } from '@material-ui/core/styles'
import Checkbox from '@material-ui/core/Checkbox'
import ClickAwayListener from '@material-ui/core/ClickAwayListener'
import FormControl from '@material-ui/core/FormControl'
import FormControlLabel from '@material-ui/core/FormControlLabel'
import FormGroup from '@material-ui/core/FormGroup'
import FormLabel from '@material-ui/core/FormLabel'
import ArrowDownwardIcon from '@material-ui/icons/ArrowDownward'
import ArrowUpwardIcon from '@material-ui/icons/ArrowUpward'
import FilterListIcon from '@material-ui/icons/FilterList'
import SortIcon from '@material-ui/icons/Sort'

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
    '& .is_sorted_even_cell': {
      backgroundColor: '#d3d6ff',
    },
    '& .is_sorted_odd_cell': {
      backgroundColor: '#e2e5ff',
    },
    '& .is_not_sorted_even_cell': {
      backgroundColor: '#e2e5ff',
    },
    '& .is_not_sorted_odd_cell': {
      backgroundColor: '#fff',
    },
    '& th,td': {
      margin: 0,
      padding: '0.8rem 0.3rem',
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
    '& th .arrow-icon': {
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

const Table = ({ columns, data, WBid, tableType }) => {
  console.log(data)
  const classes = useStyles()

  const [displayFilter, setDisplayFilter] = useState({
    phentypeLabel: false,
    interaction_type: false,
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
      numberWithScientificNotation: (rowA, rowB, columnId) => {
        const NumberdEValueOfRowA = Number(rowA.values[columnId])
        const NumberdEValueOfRowB = Number(rowB.values[columnId])
        if (NumberdEValueOfRowA < NumberdEValueOfRowB) {
          return -1
        } else if (NumberdEValueOfRowA > NumberdEValueOfRowB) {
          return 1
        } else return 0
      },
      sortBySpecies: (rowA, rowB, columnId) => {
        const comparisonStandardOfRowA = `${rowA.values[columnId].genus}${rowA.values[columnId].species}`
        const comparisonStandardOfRowB = `${rowB.values[columnId].genus}${rowB.values[columnId].species}`
        return comparisonStandardOfRowA > comparisonStandardOfRowB
          ? 1
          : comparisonStandardOfRowA < comparisonStandardOfRowB
          ? -1
          : 0
      },
      sortByMethods: (rowA, rowB, columnId) => {
        const comparisonStandardOfRowA = rowA.values[columnId][0].label
        const comparisonStandardOfRowB = rowB.values[columnId][0].label
        return comparisonStandardOfRowA > comparisonStandardOfRowB
          ? 1
          : comparisonStandardOfRowA < comparisonStandardOfRowB
          ? -1
          : 0
      },
    }),
    []
  )

  const filterTypes = useMemo(
    () => ({
      /*
        id[0] is "phenotype.label",
        id[1] is "interactions",
        id[2] is "interactions_type",
        id[3] is "citations"
        */
      globalFilterType0: (rows, id, filterValue) => {
        console.log(id)
        const keyFunc = (row) => {
          console.log(row)
          /*
          id[0] is "evalue",
          id[1] is "taxonomy",
          id[2] is "hit.label"
          id[3] is "description"
          id[4] is "percent"
          */
          let keyArr = []
          const rowVals = row.values

          keyArr.push(Number(rowVals[id[0]]))
          keyArr.push(`${rowVals[id[1]].genus}. ${rowVals[id[1]].species}`)
          keyArr.push(rowVals[id[2]])
          keyArr.push(rowVals[id[3]])
          keyArr.push(Number(rowVals[id[4]]))
          return keyArr
        }

        return matchSorter(rows, filterValue, { keys: [(row) => keyFunc(row)] })
      },
      globalFilterType1: (rows, id, filterValue) => {
        const keyFunc = (row) => {
          /*
          id[0] is "species",
          id[1] is "ortholog.label",
          id[2] is "method"
          */
          let keyArr = []
          const rowVals = row.values
          keyArr.push(`${rowVals[id[0]].genus}. ${rowVals[id[0]].species}`)
          keyArr.push(rowVals[id[1]])
          keyArr.push(rowVals[id[2]].map((r) => r.label))
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

  const displayFilterFn = (column) => {
    if (
      (column.id === 'phenotype.label' && displayFilter['phenotypeLabel']) ||
      (column.id === 'interaction_type' && displayFilter['interaction_type'])
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
    const { phenotypeLabel, interaction_type } = displayFilter

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
                checked={interaction_type}
                onChange={handleChange}
                name='interaction_type'
              />
            }
            label='Interaction Type'
          />
        </FormGroup>
      </FormControl>
    )
  }

  const selectGlobalFilter = (tableType) => {
    if (tableType === 'best_blastp_matches') {
      return 'globalFilterType0'
    }
    if (tableType === 'nematode_orthologs' || tableType === 'other_orthologs') {
      return 'globalFilterType1'
    }
    return null
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
      globalFilter: selectGlobalFilter(tableType),
      initialState: {
        pageIndex: 0,
        pageSize: 10,
        sortBy: [{ id: 'species', desc: false }],
      },
    },
    useBlockLayout,
    useFilters,
    useGlobalFilter,
    useResizeColumns,
    useSortBy,
    useExpanded,
    usePagination
  )

  return (
    <div className={classes.container}>
      <div className={classes.displayed_data_info}>
        <span>{rows.length} entries</span>
      </div>
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
                          <ArrowDownwardIcon className='arrow-icon' />
                        ) : (
                          <ArrowUpwardIcon className='arrow-icon' />
                        )
                      ) : (
                        <SortIcon className='arrow-icon' />
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
          {page.map((row, idx) => {
            prepareRow(row)
            return (
              <tr {...row.getRowProps()}>
                {row.cells.map((cell) => {
                  return (
                    <td
                      {...cell.getCellProps()}
                      className={
                        cell.column.isSorted
                          ? idx % 2 === 0
                            ? 'is_sorted_even_cell'
                            : 'is_sorted_odd_cell'
                          : idx % 2 === 0
                          ? 'is_not_sorted_even_cell'
                          : 'is_not_sorted_odd_cell'
                      }
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

export default Table
