import React, { useMemo } from 'react';
import Table from './Table';
import TableHasGroupedRow from './TableHasGroupedRow';
import { decideSortType } from '../util/sortTypeHelper';
import SmartCell from './SmartCell';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles({
  columnHeader: {
    fontSize: '1.1rem',
    fontWeight: '600',
    color: '#666',
  },
});

const Generic = ({
  data,
  id,
  columnsHeader,
  order,
  hasGroupedRow,
  dataForTsv,
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
          dataForTsv={dataForTsv}
        />
      ) : (
        <Table
          columns={columns}
          data={data}
          id={id}
          order={order}
          dataForTsv={dataForTsv}
        />
      )}
    </>
  );
};

export default Generic;
