import React from 'react';
import Table, { TableFooter, TableRow, TablePagination } from 'material-ui/Table';

const Pagination = (props) => (
  <Table>
    <TableFooter>
      <TableRow>
        <TablePagination {...props} />
      </TableRow>
    </TableFooter>
  </Table>
);

export default Pagination;

export {
  TablePagination
};
