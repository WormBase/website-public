import React from 'react';
import classNames from 'classnames';
import MuiTooltip from '@material-ui/core/Tooltip';

export default ({className, ...others}) => (
  <MuiTooltip
    className={classNames('wb-qtip-ignore', className)}
    {...others}
  />
);
