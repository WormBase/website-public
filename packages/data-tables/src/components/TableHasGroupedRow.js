import React, { useState, useCallback, useEffect } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import ArrowDownwardIcon from '@material-ui/icons/ArrowDownward';
import ArrowUpwardIcon from '@material-ui/icons/ArrowUpward';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import ExpandLessIcon from '@material-ui/icons/ExpandLess';
import SortIcon from '@material-ui/icons/Sort';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Switch from '@material-ui/core/Switch';
import Tsv from './Tsv';
import SmartCell from './SmartCell';
import TableCellExpandAllContext from './TableCellExpandAllContext';
import GlobalFilter from './GlobalFilter';

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
    '& $nEntries': {
      marginRight: 15,
    },
  },
  nEntries: {},
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
    verticalAlign: 'middle',
  },
}));

const TableHasGroupedRow = ({
  columns,
  data,
  id,
  dataForTsv,
  order,
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

  // useExpanded
  toggleAllRowsExpanded,

  state: { pageIndex, pageSize, globalFilter },
}) => {
  const classes = useStyles();

  const [isCellExpanded, setCellExpanded] = useState(false);
  const handleCellExpandedToggle = useCallback(
    (event) => {
      setCellExpanded(!isCellExpanded);
    },
    [isCellExpanded, setCellExpanded]
  );

  useEffect(() => {
    toggleAllRowsExpanded(isCellExpanded);
  }, [isCellExpanded, toggleAllRowsExpanded]);

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
    if (cell.isGrouped) {
      return (
        <>
          {row.isExpanded ? (
            <ExpandLessIcon fontSize="small" className={classes.rowArrowIcon} />
          ) : (
            <ExpandMoreIcon fontSize="small" className={classes.rowArrowIcon} />
          )}
          <SmartCell data={row.subRows[0].values['phenotype']} />
          <small>{` ${row.subRows.length} annotation(s)`}</small>
        </>
      );
    } else if (cell.isAggregated) {
      return cell.render('Aggregated');
    } else if (cell.isPlaceholder) {
      return null;
    } else {
      return cell.render('Cell');
    }
  };

  return (
    <div className={classes.wrapper}>
      <div {...getTableProps()}>
        <div className={classes.subElement}>
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
          <span className={classes.nEntries}>{rows.length} entries</span>
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
            <TableCellExpandAllContext.Provider value={isCellExpanded}>
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
