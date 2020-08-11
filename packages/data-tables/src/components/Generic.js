import React, { useMemo } from 'react';
import Table from './Table';
import TableHasGroupedRow from './TableHasGroupedRow';
import { decideSortType } from '../util/sortTypeHelper';
import SmartCell from './SmartCell';
import { makeStyles } from '@material-ui/core/styles';
import unwind from 'javascript-unwind';

const useStyles = makeStyles({
  columnHeader: {
    fontSize: '1.1rem',
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
    return order.map((ord) => {
      return {
        Header: () => (
          <span className={classes.columnHeader}>
            {columnsHeader[`${ord}`]}
          </span>
        ),
        accessor: ord,
        Cell: ({ cell: { value } }) => {
          if (hasGroupedRow && value === null) {
            return <span>N/A</span>;
          }
          return <SmartCell data={value} />;
        },
        sortType: (rowA, rowB, columnId) => {
          return decideSortType(rowA, rowB, columnId);
        },
        Aggregated: () => null,
      };
    });
  }, []);

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
