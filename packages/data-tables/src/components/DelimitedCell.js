import React from 'react';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core/styles';
import { hasContent } from '../util/hasContent';

const useStyles = makeStyles((theme) => ({
  list: {
    margin: 0,
    padding: 0,
  },
  listItem: {
    margin: 0,
    padding: 0,
  },
}));

const DelimitedCell = (props) => {
  const { data = [], delimiter = ' ', render } = props;
  const classes = useStyles();

  return (
    <div className={classes.list}>
      {data
        .filter((dat) => hasContent(dat))
        .map((dat, index) => (
          <>
            {index === 0 ? null : delimiter}
            <span key={index} className={classes.listItem}>
              {render({ elementData: dat })}
            </span>
          </>
        ))}
    </div>
  );
};

DelimitedCell.propTypes = {
  data: PropTypes.arrayOf(PropTypes.any),
  render: PropTypes.func,
};

export default DelimitedCell;
