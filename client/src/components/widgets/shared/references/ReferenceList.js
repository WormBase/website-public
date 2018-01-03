import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Pagination from '../../../Pagination';

export default class ReferenceList extends Component {
  static propTypes = {
    data: PropTypes.arrayOf(
      PropTypes.shape({
        year: PropTypes.any,
      }),
    ).isRequired,
    children: PropTypes.func.isRequired,
  };

  constructor(props) {
    super(props);
    this.state = {
      page: 0,
      rowsPerPage: 5,
    };
  }

  handleChangePage = (event, page) => {
    this.setState({
      page: page,
    });
  }

  handleChangeRowsPerPage = (event) => {
    this.setState({
      rowsPerPage: event.target.value
    });
  }

  filterData = (data) => {
    return data.filter((row) => true);
  };

  compareYear = (rowA, rowB) => {
    const parseRowYear = (row) => {
      return parseInt(row.year, 10) || -1;
    }
    return parseRowYear(rowB) - parseRowYear(rowA);
  }

  render() {
    const {page, rowsPerPage} = this.state;
    const data = this.filterData(this.props.data).sort(this.compareYear);
    const pageData = data.slice(page * rowsPerPage, Math.min(data.length, page * rowsPerPage + rowsPerPage));
    return (
      <div>
        {
          this.props.children(pageData)
        }
        <Pagination
          count={data.length}
          rowsPerPage={rowsPerPage}
          page={page}

          onChangePage={this.handleChangePage}
          onChangeRowsPerPage={this.handleChangeRowsPerPage}
        />
      </div>
    );
  }
}
