import React, { useState, useCallback } from 'react';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core/styles';
import { hasContent } from '../util/hasContent';
import SimpleCell from './SimpleCell';

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
  moreOrLess: {
    fontSize: '0.8em',
    marginBottom: `${theme.spacing(0.5)}px`,
  },
}));

const ListCell = (props) => {
  const { data = [], render, collapsedItemCount = 1 } = props;
  const classes = useStyles();
  const [isOpen, setOpen] = useState(false);

  const toggleOpen = useCallback(() => {
    setOpen(!isOpen);
  }, [isOpen, setOpen]);

  return (
    <ul
      className={classes.list}
      style={{
        cursor: data.length > collapsedItemCount ? 'pointer' : 'default',
      }}
      onClick={toggleOpen}
    >
      {data
        .filter((dat) => hasContent(dat))
        .filter((dat, index) => isOpen || index < collapsedItemCount)
        .map((dat, index) => (
          <li key={index} className={classes.listItem}>
            {render({ elementData: dat })}
          </li>
        ))}
      {data.length > collapsedItemCount ? (
        isOpen ? (
          <li className={classes.moreOrLess}> show less</li>
        ) : (
          <li className={classes.moreOrLess}> and {data.length - 1} more</li>
        )
      ) : null}
    </ul>
  );
};

ListCell.propTypes = {
  data: PropTypes.arrayOf(PropTypes.any),
  render: PropTypes.func,
  collapsedItemCount: PropTypes.number,
};

export default ListCell;
