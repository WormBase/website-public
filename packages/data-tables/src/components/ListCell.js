import React from 'react';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core/styles';
import { hasContent } from '../util/hasContent';

const useStyles = makeStyles((theme) => ({
  list: {
    margin: 0,
    padding: 0,
    listStyleType: 'none',
  },
  listItem: {
    margin: 0,
    padding: 0,
  },
}));

const ListCell = ({ data, render }) => {
  const classes = useStyles();
  return (
    <ul className={classes.list}>
      {data
        .filter((dat) => hasContent(dat))
        .map((dat, index) => (
          <li key={index} className={classes.listItem}>
            {render({ elementData: dat })}
          </li>
        ))}
    </ul>
  );
};

ListCell.propTypes = {
  data: PropTypes.arrayOf(PropTypes.any),
  render: PropTypes.func,
};

export default ListCell;
