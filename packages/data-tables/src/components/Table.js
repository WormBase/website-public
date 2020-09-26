import React, { useState, useCallback, useEffect, useMemo } from 'react';
import { makeStyles } from '@material-ui/core/styles';
import Grid from '@material-ui/core/Grid';
import ArrowDownwardIcon from '@material-ui/icons/ArrowDownward';
import ArrowUpwardIcon from '@material-ui/icons/ArrowUpward';
import ArrowDropDownIcon from '@material-ui/icons/ArrowDropDown';
import ArrowRightIcon from '@material-ui/icons/ArrowRight';
import SortIcon from '@material-ui/icons/Sort';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import Switch from '@material-ui/core/Switch';
import Divider from '@material-ui/core/Divider';
import SmartCell from './SmartCell';
import Tsv from './Tsv';
import TableCellExpandAllContext from './TableCellExpandAllContext';
import GlobalFilter from './GlobalFilter';

const useStyles = makeStyles((theme) => ({
  wrapper: {
    display: 'block',
    overflow: 'auto',
    backgroundColor: '#e9eef2',
    border: `1px solid ${theme.palette.divider}`,
    borderRadius: theme.shape.borderRadius,
    clear: 'both',
  },
  table: {
    color: '#444',
    borderSpacing: 0,
    border: 0,
    '& .thead': {
      backgroundColor: '#e9eef2',
    },
    '& .tbody': {
      borderTop: `1px solid ${theme.palette.divider}`,
      borderBottom: `1px solid ${theme.palette.divider}`,
    },
    '& $rowGrouped.tr > *': {
      background: theme.palette.background.default,
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
      padding: `${theme.spacing(1)}px ${theme.spacing(1)}px`,
      // borderBottom: '1px solid #ededed',
      // borderRight: '1px solid #fff',
      position: 'relative',
    },
    '& .td': {
      // padding: '0.1rem 0.3rem',
    },
    '& .th:last-child, .td:last-child': {
      borderRight: 0,
    },
    '& .th .resizer': {
      display: 'inline-block',
      width: 0,
      height: '100%',
      position: 'absolute',
      right: 0,
      top: 0,
      zIndex: 1,
      touchAction: 'none',
      boxSizing: 'border-box',
      padding: `${theme.spacing(1)}px 0`,
    },
    '& .th .isResizing': {
      background: '#828A95',
    },
    '& .th .filter input': {
      width: '80%',
    },
    '& .th .column_header': {
      textAlign: 'left',
      display: 'flex',
      justifyContent: 'space-between',
    },
    '& .th .arrow-icon': {
      fontSize: '1rem',
      marginLeft: 5,
    },
  },
  rowGrouped: {},
  rowArrowIcon: {
    marginRight: 10,
    verticalAlign: 'middle',
  },
  subElement: {
    fontSize: '0.8em',
    paddingRight: theme.spacing(2),
    display: 'inline-block',
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

const isCellExpandable = (value) => {
  console.log(value);
  if (Array.isArray(value) && value.length > 1) {
    return true;
  } else if (
    typeof value === 'object' &&
    value !== null &&
    value.text &&
    value.evidence
  ) {
    return true;
  } else {
    return false;
  }
};

const Table = ({
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
  pageCount,
  pageOptions,
  gotoPage,
  nextPage,
  previousPage,
  setPageSize,
  setGlobalFilter,

  // useExpanded
  toggleAllRowsExpanded,

  // custom
  hideCellExpandToggle = false,

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

  const showCellExpandToggle = useMemo(() => {
    return (
      !hideCellExpandToggle &&
      page.reduce((expandablePage, row) => {
        return (
          expandablePage ||
          row.isGrouped ||
          Object.values(row.values).reduce(
            (expandableRow, value) => expandableRow || isCellExpandable(value),
            expandablePage
          )
        );
      }, false)
    );
  }, [page, hideCellExpandToggle]);

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

  const renderCell = (cell, row) => {
    if (cell.isGrouped) {
      const groupByID = row.groupByID.split('.')[0];

      return (
        <>
          {row.isExpanded ? (
            <ArrowDropDownIcon className={classes.rowArrowIcon} />
          ) : (
            <ArrowRightIcon className={classes.rowArrowIcon} />
          )}
          <SmartCell data={row.subRows[0].values[groupByID]} />
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

  const pageSizeOptions = useMemo(() => {
    return [10, 25, Math.min(100, rows.length)];
  }, [rows.length]);

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
              {pageSizeOptions
                .filter(
                  (pageSize, pageSizeIndex) =>
                    pageSize <= rows.length &&
                    pageSizeOptions.indexOf(pageSize) === pageSizeIndex
                )
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
            {showCellExpandToggle ? (
              <FormControlLabel
                control={
                  <Switch
                    checked={isCellExpanded}
                    onChange={handleCellExpandedToggle}
                    name="expand-all"
                    inputProps={{ 'aria-label': 'secondary checkbox' }}
                  />
                }
                label={
                  isCellExpanded ? 'Details expanded' : 'Details collapsed'
                }
              />
            ) : null}
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
                    >
                      <Divider orientation="vertical" />
                    </div>
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
                  <div
                    className={
                      row.isGrouped ? 'tr ' + classes.rowGrouped : 'tr'
                    }
                    {...(row.isGrouped
                      ? row.getRowProps(row.getToggleRowExpandedProps())
                      : row.getRowProps())}
                  >
                    {row.cells.map((cell) => {
                      return (
                        <div
                          {...cell.getCellProps()}
                          className={decideClassNameOfCell(cell, idx)}
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
