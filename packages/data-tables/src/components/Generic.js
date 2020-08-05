import React, { useMemo } from 'react';
import Table from './Table';
import TableHasGroupedRow from './TableHasGroupedRow';
import CellContent from './CellContent';
import { decideSortType } from '../util/sortTypeHelper';

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
          return <CellContent cell={value} />;
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
