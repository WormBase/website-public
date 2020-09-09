import React, { useMemo, useState, useCallback } from 'react';
import {
  useAsyncDebounce,
  useFlexLayout,
  useFilters,
  useGlobalFilter,
  useResizeColumns,
  useSortBy,
  useExpanded,
  usePagination,
  useTable,
} from 'react-table';
import matchSorter from 'match-sorter';
import { makeStyles } from '@material-ui/core/styles';
import Grid from '@material-ui/core/Grid';
import ArrowDownwardIcon from '@material-ui/icons/ArrowDownward';
import ArrowUpwardIcon from '@material-ui/icons/ArrowUpward';
import SortIcon from '@material-ui/icons/Sort';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Switch from '@material-ui/core/Switch';
import Tsv from './Tsv';
import TableCellExpandAllContext from './TableCellExpandAllContext';

const useStyles = makeStyles((theme) => ({
  wrapper: {
    display: 'block',
    overflow: 'auto',
    backgroundColor: '#e9eef2',
  },
  table: {
    color: '#444',
    borderSpacing: 0,
    border: '1px solid #ededed',
    '& .thead': {
      backgroundColor: '#e9eef2',
    },
    '& .tr:last-child .td': {
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
    '& .th, .td': {
      margin: 0,
      padding: '0.5rem 0.3rem',
      borderBottom: '1px solid #ededed',
      borderRight: '1px solid #ededed',
      position: 'relative',
    },
    '& .td': {
      padding: '0.1rem 0.3rem',
    },
    '& .th:last-child, .td:last-child': {
      borderRight: 0,
    },
    '& .th .resizer': {
      display: 'inline-block',
      width: 10,
      height: '100%',
      position: 'absolute',
      right: 0,
      top: 0,
      zIndex: 1,
      touchAction: 'none',
    },
    '& .th .isResizing': {
      background: '#828A95',
    },
    '& .th .filter input': {
      width: '80%',
    },
    '& .th .column_header': {
      textAlign: 'left',
    },
    '& .th .arrow-icon': {
      fontSize: '1rem',
      marginLeft: 5,
    },
  },
  subElement: {
    fontSize: '0.8em',
    paddingRight: theme.spacing(2),
  },
  toolbarWrapper: {
    overflow: 'hidden', // work around -4px margin in Grid
  },
  toolbar: {
    padding: `${theme.spacing(0.5)}px ${theme.spacing(0.5)}px 0`,

    '& input': {
      flex: '1 0 auto',
      [theme.breakpoints.up('sm')]: {
        flex: '0 0 auto',
      },
    },

    '& input:focus': {
      flex: '1 0 auto',
    },
  },
  pagination: {
    padding: '0.8rem 0.5rem',
  },
}));

const GlobalFilter = ({ globalFilter, setGlobalFilter }) => {
  const [value, setValue] = useState(globalFilter);
  const onChange = useAsyncDebounce((value) => {
    setGlobalFilter(value || undefined);
  }, 200);

  return (
    <input
      value={value || ''}
      onChange={(e) => {
        setValue(e.target.value);
        onChange(e.target.value);
      }}
      placeholder={`Search all columns...`}
      type="search"
    />
  );
};

const Table = ({ columns, data, id, dataForTsv, order }) => {
  const classes = useStyles();

  const filterTypes = useMemo(() => {
    const storeValuesOfNestedObj = (obj, keyArr) => {
      for (const key in obj) {
        if (typeof obj[key] === 'object' && obj[key] !== null) {
          if (
            obj[key].class &&
            obj[key].id &&
            obj[key].label &&
            obj[key].taxonomy
          ) {
            keyArr.push(obj[key].label);
          }
          if (Array.isArray(obj[key]) && typeof obj[key][0] === 'object') {
            if (
              obj[key][0].class &&
              obj[key][0].id &&
              obj[key][0].label &&
              obj[key][0].taxonomy
            ) {
              keyArr.push(obj[key].map((o) => o.label));
            } else if (obj[key][0].pato_evidence) {
              keyArr.push(
                ...obj[key].map((o) => [
                  o.pato_evidence.entity_term.label,
                  o.pato_evidence.entity_type,
                  o.pato_evidence.pato_term,
                ])
              );
            } else {
              console.error(
                'Data is surely array of Object. But it is not Tagtype data.'
              );
              console.error(key);
              console.error(obj[key]);
            }
          } else {
            storeValuesOfNestedObj(obj[key], keyArr);
          }
        } else {
          keyArr.push(obj[key]);
        }
      }
    };

    return {
      defaultFilter: (rows, id, filterValue) => {
        const keyFunc = (row) => {
          let keyArr = [];
          const rowVals = row.values;

          id.forEach((i) => {
            if (typeof rowVals[i] === 'object') {
              storeValuesOfNestedObj(rowVals[i], keyArr);
            } else {
              keyArr.push(rowVals[i]);
            }
          });

          return keyArr;
        };

        return matchSorter(rows, filterValue, {
          keys: [(row) => keyFunc(row)],
          threshold: matchSorter.rankings.CONTAINS,
        });
      },
    };
  }, []);

  const defaultColumnFilter = ({ column: { filterValue, setFilter } }) => {
    return (
      <input
        value={filterValue || ''}
        onChange={(e) => {
          setFilter(e.target.value || undefined);
        }}
        placeholder={`Search...`}
        type="search"
      />
    );
  };

  const defaultColumn = useMemo(
    () => ({
      filter: 'defaultFilter',
      Filter: defaultColumnFilter,
      minWidth: 120,
      width: 180,
      maxWidth: 600,
    }),
    []
  );

  const renderIcon = (column) => {
    if (column.canSort) {
      if (column.isSorted) {
        if (column.isSortedDesc) {
          return <ArrowDownwardIcon className="arrow-icon" />;
        }
        return <ArrowUpwardIcon className="arrow-icon" />;
      }
      return <SortIcon className="arrow-icon" />;
    }
    return null;
  };

  const decideClassNameOfCell = (cell, idx) => {
    if (cell.column.isSorted) {
      if (idx % 2 === 0) {
        return 'is_sorted_even_cell td';
      }
      return 'is_sorted_odd_cell td';
    }
    if (idx % 2 === 0) {
      return 'is_not_sorted_even_cell td';
    }
    return 'is_not_sorted_odd_cell td';
  };

  const [isCellExpanded, setCellExpanded] = useState(false);
  const handleCellExpandedToggle = useCallback(
    (event) => {
      setCellExpanded(!isCellExpanded);
    },
    [isCellExpanded, setCellExpanded]
  );

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
      disableSortRemove: true,
      filterTypes,
      defaultColumn,
      globalFilter: 'defaultFilter',
      initialState: {
        pageIndex: 0,
        pageSize: 10,
        sortBy: [{ id: columns[0].accessor, desc: false }],
      },
    },
    useFlexLayout,
    useFilters,
    useGlobalFilter,
    useResizeColumns,
    useSortBy,
    useExpanded,
    usePagination
  );

  return (
    <div className={classes.wrapper}>
      <div className={classes.toolbarWrapper}>
        <Grid
          container
          spacing={1}
          justify="space-between"
          className={classes.toolbar}
        >
          <Grid item xs={12} sm={6} className={classes.count}>
            <select
              value={pageSize}
              onChange={(e) => {
                setPageSize(Number(e.target.value));
              }}
            >
              {[10, 25, Math.min(100, rows.length)]
                .filter((pageSize) => pageSize <= rows.length)
                .map((pageSize) => (
                  <option key={pageSize} value={pageSize}>
                    Show {pageSize === rows.length ? 'All' : pageSize}
                  </option>
                ))}
            </select>
            {' of '}
            <strong>{rows.length}</strong> entries{' '}
            <span className={classes.subElement}>
              [<Tsv data={dataForTsv || data} id={id} order={order} />]
            </span>
            <FormControlLabel
              control={
                <Switch
                  checked={isCellExpanded}
                  onChange={handleCellExpandedToggle}
                  name="expand-all"
                  inputProps={{ 'aria-label': 'secondary checkbox' }}
                />
              }
              label={isCellExpanded ? 'Details expanded' : 'Details collapsed'}
            />
          </Grid>
          <Grid
            item
            container
            justify="flex-end"
            alignItems="center"
            xs={12}
            sm={6}
          >
            <GlobalFilter
              globalFilter={globalFilter}
              setGlobalFilter={setGlobalFilter}
            />
          </Grid>
        </Grid>
      </div>
      <div {...getTableProps()}>
        <div className={classes.table}>
          <div className="thead">
            {headerGroups.map((headerGroup) => (
              <div className="tr" {...headerGroup.getHeaderGroupProps()}>
                {headerGroup.headers.map((column) => (
                  <div className="th" {...column.getHeaderProps()}>
                    <div
                      {...column.getSortByToggleProps()}
                      className="column_header"
                    >
                      {column.render('Header')}
                      {renderIcon(column)}
                    </div>
                    <div
                      {...column.getResizerProps()}
                      className={`resizer ${
                        column.isResizing ? 'isResizing' : ''
                      }`}
                    />
                  </div>
                ))}
              </div>
            ))}
          </div>
          <div className="tbody" {...getTableBodyProps()}>
            <TableCellExpandAllContext.Provider value={isCellExpanded}>
              {page.map((row, idx) => {
                prepareRow(row);
                return (
                  <div className="tr" {...row.getRowProps()}>
                    {row.cells.map((cell) => {
                      return (
                        <div
                          {...cell.getCellProps()}
                          className={decideClassNameOfCell(cell, idx)}
                        >
                          {cell.render('Cell')}
                        </div>
                      );
                    })}
                  </div>
                );
              })}
            </TableCellExpandAllContext.Provider>
          </div>
        </div>
        <div className={classes.pagination}>
          <button onClick={() => gotoPage(0)} disabled={!canPreviousPage}>
            {'<<'}
          </button>{' '}
          <button onClick={() => previousPage()} disabled={!canPreviousPage}>
            {'<'}
          </button>{' '}
          <span>
            Showing{' '}
            <strong>
              {Math.min(pageIndex * pageSize + 1, rows.length)} -{' '}
              {Math.min((pageIndex + 1) * pageSize, rows.length)}
            </strong>{' '}
            of <strong>{rows.length}</strong> entries
          </span>{' '}
          <button onClick={() => nextPage()} disabled={!canNextPage}>
            {'>'}
          </button>{' '}
          <button
            onClick={() => gotoPage(pageCount - 1)}
            disabled={!canNextPage}
          >
            {'>>'}
          </button>{' '}
        </div>
      </div>
    </div>
  );
};

export default Table;
