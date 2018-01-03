import React, { Component } from 'react';
import PropTypes from 'prop-types';
import Pagination from '../../../Pagination';

export default class ReferenceList extends Component {
  static propTypes = {
    data: PropTypes.array.isRequired,
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
  render() {
    const {data} = this.props;
    const {page, rowsPerPage} = this.state;
    const pageData = data.slice(page * rowsPerPage, Math.min(data.count, page * rowsPerPage + rowsPerPage));
    return (
      <div>
        {
          this.props.children(pageData)
        }
        <Pagination
          count={data.length}
          rowsPerPage={rowsPerPage}
          page={page}
          backIconButtonProps={{
            'aria-label': 'Previous Page',
          }}
          nextIconButtonProps={{
            'aria-label': 'Next Page',
          }}
          onChangePage={this.handleChangePage}
          onChangeRowsPerPage={this.handleChangeRowsPerPage}
        />
      </div>
    );
  }
}
