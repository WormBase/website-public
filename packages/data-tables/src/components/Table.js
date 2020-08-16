import React, { useMemo, useState } from 'react';
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
import ArrowDownwardIcon from '@material-ui/icons/ArrowDownward';
import ArrowUpwardIcon from '@material-ui/icons/ArrowUpward';
import SortIcon from '@material-ui/icons/Sort';
import Tsv from './Tsv';

const useStyles = makeStyles((theme) => ({
  wrapper: {
    display: 'block',
    overflow: 'auto',
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
      padding: '0.8rem 0.3rem',
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
    textAlign: 'right',
    '& span': {
      marginRight: 15,
    },
  },
  globalFilter: {
    backgroundColor: '#e9eef2',
    display: 'flex',
    '& input': {
      borderRadius: 5,
      border: '1px solid #ddd',
      flex: '1 0 auto',
      margin: `${theme.spacing(1.5)}px ${theme.spacing(0.5)}px 0`,
    },
  },
  pagination: {
    padding: '0.8rem 0.5rem',
    backgroundColor: '#e9eef2',
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

  const sortTypes = useMemo(
    () => ({
      caseInsensitiveAlphaNumeric: (rowA, rowB, columnId) => {
        const getRowValueByColumnID = (row, columnId) => row.values[columnId];
        const toString = (a) => {
          if (typeof a === 'number') {
            if (isNaN(a) || a === Infinity || a === -Infinity) {
              return '';
            }
            return String(a);
          }
          if (typeof a === 'string') {
            return a;
          }
          return '';
        };
        const reSplitAlphaNumeric = /([0-9]+)/gm;

        let a = getRowValueByColumnID(rowA, columnId);
        let b = getRowValueByColumnID(rowB, columnId);
        // Force to strings (or "" for unsupported types)
        // And lowercase to accomplish insensitive sort
        a = toString(a).toLowerCase();
        b = toString(b).toLowerCase();

        // Split on number groups, but keep the delimiter
        // Then remove falsey split values
        a = a.split(reSplitAlphaNumeric).filter(Boolean);
        b = b.split(reSplitAlphaNumeric).filter(Boolean);

        // While
        while (a.length && b.length) {
          let aa = a.shift();
          let bb = b.shift();

          const an = parseInt(aa, 10);
          const bn = parseInt(bb, 10);

          const combo = [an, bn].sort();

          // Both are string
          if (isNaN(combo[0])) {
            if (aa > bb) {
              return 1;
            }
            if (bb > aa) {
              return -1;
            }
            continue;
          }

          // One is a string, one is a number
          if (isNaN(combo[1])) {
            return isNaN(an) ? -1 : 1;
          }

          // Both are numbers
          if (an > bn) {
            return 1;
          }
          if (bn > an) {
            return -1;
          }
        }

        return a.length - b.length;
      },
    }),
    []
  );

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
      sortType: 'caseInsensitiveAlphaNumeric',
      Filter: defaultColumnFilter,
      minWidth: 120,
      width: 180,
      maxWidth: 600,
    }),
    []
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
      sortTypes,
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
      <div {...getTableProps()}>
        <div className={classes.subElement}>
          <span>{rows.length} entries</span>
          <Tsv data={dataForTsv || data} id={id} order={order} />
        </div>
        <div className={classes.globalFilter}>
          <GlobalFilter
            globalFilter={globalFilter}
            setGlobalFilter={setGlobalFilter}
          />
        </div>
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
                      {column.canSort ? (
                        column.isSorted ? (
                          column.isSortedDesc ? (
                            <ArrowDownwardIcon className="arrow-icon" />
                          ) : (
                            <ArrowUpwardIcon className="arrow-icon" />
                          )
                        ) : (
                          <SortIcon className="arrow-icon" />
                        )
                      ) : (
                        ''
                      )}
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
            {page.map((row, idx) => {
              prepareRow(row);
              return (
                <div className="tr" {...row.getRowProps()}>
                  {row.cells.map((cell) => {
                    return (
                      <div
                        {...cell.getCellProps()}
                        className={
                          cell.column.isSorted
                            ? idx % 2 === 0
                              ? 'is_sorted_even_cell td'
                              : 'is_sorted_odd_cell td'
                            : idx % 2 === 0
                            ? 'is_not_sorted_even_cell td'
                            : 'is_not_sorted_odd_cell td'
                        }
                      >
                        {cell.render('Cell')}
                      </div>
                    );
                  })}
                </div>
              );
            })}
          </div>
        </div>
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
          <button
            onClick={() => gotoPage(pageCount - 1)}
            disabled={!canNextPage}
          >
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
              setPageSize(Number(e.target.value));
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
    </div>
  );
};

export default Table;
