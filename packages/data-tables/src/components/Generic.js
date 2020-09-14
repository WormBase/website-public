import React, { useMemo } from 'react';
import Table from './Table';
import TableHasGroupedRow from './TableHasGroupedRow';
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

  return (
    <>
      {hasGroupedRow ? (
        <TableHasGroupedRow
          columns={columns}
          data={data}
          id={id}
          order={order}
          dataForTsv={getDataForTsv(data, propertyForUnwinding)}
        />
      ) : (
        <Table
          columns={columns}
          data={data}
          id={id}
          order={order}
          dataForTsv={getDataForTsv(data, propertyForUnwinding)}
        />
      )}
    </>
  );
};

export default Generic;
