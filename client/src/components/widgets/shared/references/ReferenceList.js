import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Pagination from '../../../Pagination';

class ReferenceList extends Component {
  static propTypes = {
    data: PropTypes.array.isRequired,
    children: PropTypes.func.isRequired,
    classes: PropTypes.object.isRequired,
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
  };

  handleChangeRowsPerPage = (event) => {
    this.setState({
      rowsPerPage: event.target.value,
    });
  };

  render() {
    const { page, rowsPerPage } = this.state;
    const { data, classes } = this.props;
    const pageData = data.slice(
      page * rowsPerPage,
      Math.min(data.length, page * rowsPerPage + rowsPerPage)
    );
    return (
      <div className={classes.root}>
        {this.props.children(pageData)}
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

const styles = (theme) => ({
  root: {},
});

export default withStyles(styles, { withTheme: true })(ReferenceList);
