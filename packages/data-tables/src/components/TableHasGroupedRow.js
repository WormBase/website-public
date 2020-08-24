import React, { useMemo, useState } from 'react';
import {
  useAsyncDebounce,
  useFlexLayout,
  useFilters,
  useGlobalFilter,
  useGroupBy,
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
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import ExpandLessIcon from '@material-ui/icons/ExpandLess';
import SortIcon from '@material-ui/icons/Sort';
import Tsv from './Tsv';
import SimpleCell from './SimpleCell';

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
    '& .th, .td': {
      margin: 0,
      padding: '0.6rem 0.3rem',
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
    '& .tbody .tr .is_grouped, .tbody .tr .is_aggregated': {
      backgroundColor: '#dedede',
      borderRight: 'none',
    },
    '& .tbody .tr .is_other_sorted': {
      backgroundColor: '#d3d6ff',
    },
    '& .tbody .tr .is_other': {
      backgroundColor: '#e2e5ff',
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
    '& .th .sort-arrow-icon': {
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
  rowArrowIcon: {
    marginRight: 10,
    verticalAlign: 'bottom',
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

const TableHasGroupedRow = ({ columns, data, id, dataForTsv, order }) => {
  const classes = useStyles();

  const filterTypes = useMemo(() => {
    const storeValueOfNestedObj = (obj, keyArr) => {
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
            storeValueOfNestedObj(obj[key], keyArr);
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
              storeValueOfNestedObj(rowVals[i], keyArr);
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

  const getDefaultExpandedRows = (data, threshold) => {
    const defaultExpandedRows = {};
    const defaultHidRows = {};

    data.forEach((d) => {
      const key = `phenotype.label:${d.phenotype.label}`;
      if (defaultHidRows[key]) {
        defaultHidRows[key] = ++defaultHidRows[key];
      } else {
        defaultHidRows[key] = 1;
      }
    });

    data.forEach((d) => {
      const key = `phenotype.label:${d.phenotype.label}`;
      if (defaultHidRows[key] < threshold) {
        defaultExpandedRows[key] = true;
      } else {
        defaultExpandedRows[key] = false;
      }
    });

    return defaultExpandedRows;
  };

  const renderIcon = (column) => {
    if (column.canSort) {
      if (column.isSorted) {
        if (column.isSortedDesc) {
          return <ArrowDownwardIcon className="sort-arrow-icon" />;
        }
        return <ArrowUpwardIcon className="sort-arrow-icon" />;
      }
      return <SortIcon className="sort-arrow-icon" />;
    }
    return null;
  };

  const enableToggleRowExpand = (row, cell) => {
    if (cell.isGrouped || cell.isAggregated) {
      return cell.getCellProps(row.getToggleRowExpandedProps());
    }
    return cell.getCellProps();
  };

  const decideClassNameOfCell = (cell) => {
    if (cell.isGrouped) {
      return 'is_grouped td';
    }
    if (cell.isAggregated) {
      return 'is_aggregated td';
    }
    if (cell.column.isSorted) {
      return 'is_other_sorted td';
    }
    return 'is_other td';
  };

  const renderCell = (cell, row) => {
    if (cell.isAggregated) {
      return (
        <div>
          {cell.render('Aggregated')}
          {displayHiddenRowsCount(cell, row)}
        </div>
      );
    }
    if (cell.isPlaceholder) {
      return null;
    }
    return cell.render('Cell');
  };

  const displayHiddenRowsCount = (cell, row) => {
    if (cell.column.id === 'evidence') {
      return (
        <SimpleCell>
          {row.isExpanded ? (
            <ExpandLessIcon fontSize="small" className={classes.rowArrowIcon} />
          ) : (
            <ExpandMoreIcon fontSize="small" className={classes.rowArrowIcon} />
          )}
          <span>{row.subRows.length} Results</span>
        </SimpleCell>
      );
    }
  };

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
      // initialState: { pageIndex: 0 },
      paginateExpandedRows: false,
      initialState: {
        pageIndex: 0,
        pageSize: 10,
        sortBy: [{ id: columns[0].accessor, desc: false }],
        groupBy: ['phenotype.label'],
        expanded: getDefaultExpandedRows(data, 10),
      },
    },
    useFlexLayout,
    useFilters,
    useGlobalFilter,
    useResizeColumns,
    useGroupBy,
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
            {page.map((row) => {
              prepareRow(row);
              return (
                <div className="tr" {...row.getRowProps()}>
                  {row.cells.map((cell) => {
                    return (
                      <div
                        {...enableToggleRowExpand(row, cell)}
                        className={decideClassNameOfCell(cell)}
                      >
                        <div>{renderCell(cell, row)}</div>
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

export default TableHasGroupedRow;
