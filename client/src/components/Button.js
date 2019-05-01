import React from 'react';
import MuiButton from '@material-ui/core/Button';
import MuiIconButton from '@material-ui/core/IconButton';
import { withStyles } from '@material-ui/core/styles';

const Button = (props) => (
  <MuiButton disableRipple size="small" {...props} />
);

export default withStyles((theme) => ({
  label: {
    textTransform: 'none',
  },
  sizeSmall: {
    padding: `0 ${theme.spacing.unit}px`
  },
}))(Button);

const IconButton = withStyles((theme) => ({
  root: {
    padding: theme.spacing.unit / 2,
    borderRadius: '10%',
  },
}))(({classes, ...props}) => (
  <MuiIconButton
    classes={{
      root: classes.root
    }}
    disableRipple
    {...props}
  />
));

export {
  IconButton,
};
