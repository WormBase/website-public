import React, { useMemo } from 'react';
import {
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
import Table from './Table';
import { decideSortType } from '../util/sortTypeHelper';
import SmartCell from './SmartCell';
import { makeStyles } from '@material-ui/core/styles';
import unwind from 'javascript-unwind';
import ReactHtmlParser from 'react-html-parser';

const useStyles = makeStyles({
  columnHeader: {
    fontWeight: '600',
    color: '#666',
  },
});

const getDataForTsv = (data, property) => {
  if (property) {
    return data.length === 0 ? null : unwind(data, `${property}`);
  }
  return null;
};

const disableSort = (data, ord) => {
  const ArrayHasMoreThanOneElement = (dat) =>
    Array.isArray(dat[ord]) && dat[ord].length > 1;

  if (data.some(ArrayHasMoreThanOneElement)) {
    return true;
  }
  return false;
};

const Generic = ({
  data,
  id,
  columnsHeader,
  order,
  hasGroupedRow,
  propertyForUnwinding,
  tableConfig,
}) => {
  const classes = useStyles();

  const columns = useMemo(() => {
    const columnsTemp = order.map((ord, idx) => {
      return {
        Header: () => (
          <span className={classes.columnHeader}>
            {ReactHtmlParser(columnsHeader[`${ord}`])}
          </span>
        ),
        accessor: ord,
        Cell: ({ cell: { value } }) => {
          return <SmartCell data={value} />;
        },
        sortType: (rowA, rowB, columnId) => {
          try {
            return decideSortType(rowA, rowB, columnId);
          } catch (err) {
            console.error(err);
          }
        },
        disableSortBy: hasGroupedRow ? true : disableSort(data, ord),
      };
    });

    if (hasGroupedRow) {
      // add the grouped column
      columnsTemp.push({
        accessor: `${order[0]}.label`,
        Header: () => (
          <span className={classes.columnHeader}>
            {columnsHeader[`${order[0]}`]}
          </span>
        ),
      });
    }

    return columnsTemp;
  }, [classes.columnHeader, columnsHeader, data, hasGroupedRow, order]);

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

  const defaultColumn = useMemo(
    () => ({
      filter: 'defaultFilter',
      minWidth: 80,
      width: 120,
      maxWidth: 600,
    }),
    []
  );

  const initialState = useMemo(() => {
    return hasGroupedRow
      ? {
          pageIndex: 0,
          pageSize: 10,
          sortBy: [{ id: `${columns[0].accessor}.label`, desc: false }],
          groupBy: [`${columns[0].accessor}.label`],
          hiddenColumns: [`${columns[0].accessor}`],
        }
      : {
          pageIndex: 0,
          pageSize: 10,
          sortBy: [{ id: columns[0].accessor, desc: false }],
        };
  }, [hasGroupedRow, columns]);

  const tableOptions = useMemo(() => {
    const defaultTableConfig = {
      columns,
      data,
      disableSortRemove: true,
      filterTypes,
      defaultColumn,
      globalFilter: 'defaultFilter',
      // initialState: { pageIndex: 0 },
      paginateExpandedRows: false,
      initialState: initialState,
    };
    return tableConfig ? tableConfig(defaultTableConfig) : defaultTableConfig;
  }, [columns, data, filterTypes, defaultColumn, initialState, tableConfig]);

  const tableProps = useTable(
    tableOptions,
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
    <Table
      columns={columns}
      data={data}
      id={id}
      order={order}
      dataForTsv={getDataForTsv(data, propertyForUnwinding)}
      {...tableProps}
    />
  );
};

export default Generic;
