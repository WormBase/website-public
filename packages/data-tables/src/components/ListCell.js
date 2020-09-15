import React, { useState, useCallback, useContext, useEffect } from 'react';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core/styles';
import { hasContent } from '../util/hasContent';
import TableCellExpandAllContext from './TableCellExpandAllContext';

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

    '&:hover': {
      textDecoration: 'underline',
    },
  },
}));

const ListCell = (props) => {
  const { data = [], render, collapsedItemCount = 1 } = props;
  const classes = useStyles();
  const [isOpen, setOpen] = useState(false);

  const expandedFromContext = useContext(TableCellExpandAllContext);

  useEffect(() => {
    setOpen(expandedFromContext);
  }, [expandedFromContext, setOpen]);

  const toggleOpen = useCallback(() => {
    setOpen(!isOpen);
  }, [isOpen, setOpen]);

  return (
    <ul
      className={classes.list}
      style={{
        cursor: data.length > collapsedItemCount ? 'pointer' : 'default',
      }}
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
          <li className={classes.moreOrLess} onClick={toggleOpen}>
            {' '}
            show less
          </li>
        ) : (
          <li className={classes.moreOrLess} onClick={toggleOpen}>
            {' '}
            and {data.length - 1} more
          </li>
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
