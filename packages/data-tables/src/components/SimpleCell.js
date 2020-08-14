import React from 'react';
import PropTypes from 'prop-types';
import Link from './Link';
import { makeStyles } from '@material-ui/core/styles';

const useStyles = makeStyles((theme) => ({
  root: {
    margin: `${theme.spacing(0.5)}px 0`,
  },
}));

const SimpleCell = ({ data }) => {
  const classes = useStyles();
  let content;

  if (data !== null && typeof data === 'object') {
    if (data.text && typeof data.text !== 'object') {
      content = data.text;
    } else if (data.class) {
      content = <Link {...data} />;
    } else {
      content = JSON.stringify(data);
    }
  } else {
    content = data;
  }

  return <div className={classes.root}>{content}</div>;
};

SimpleCell.propTypes = {
  data: PropTypes.any,
};

export default SimpleCell;
