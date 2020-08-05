import React, { useMemo } from 'react';
import Table from './Table';
import TableHasGroupedRow from './TableHasGroupedRow';
import { decideSortType } from '../util/sortTypeHelper';
import SmartCell from './SmartCell';

const Generic = ({ data, id, columnsHeader, order, hasGroupedRow }) => {
  const columns = useMemo(() => {
    return order.map((ord) => {
      return {
        Header: columnsHeader[`${ord}`],
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
        <TableHasGroupedRow columns={columns} data={data} id={id} />
      ) : (
        <Table columns={columns} data={data} id={id} />
      )}
    </>
  );
};

export default Generic;
