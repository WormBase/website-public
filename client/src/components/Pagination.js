import React from 'react';
import Table from '@material-ui/core/Table';
import TableFooter from '@material-ui/core/TableFooter';
import TableRow from '@material-ui/core/TableRow';
import TablePagination from '@material-ui/core/TablePagination';

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
