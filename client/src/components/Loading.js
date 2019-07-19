import React from 'react';
import { withStyles } from '@material-ui/core/styles';
import classNames from 'classnames';

function Loading({ classes, classNameProp, center }) {
  const className = classNames(
    classes.root,
    {
      [classes.center]: center,
    },
    classNameProp
  );
  return (
    <div className={className}>
      <img src="/img/ajax-loader.gif" alt="Loading graph..." />
    </div>
  );
}

const styles = {
  root: {
    height: 24,
    width: 24,
  },
  center: {
    position: 'absolute',
    margin: 'auto',
    top: 0,
    left: 0,
    bottom: 0,
    right: 0,
  },
};

export default withStyles(styles)(Loading);
