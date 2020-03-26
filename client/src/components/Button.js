import React from 'react';
import MuiButton from '@material-ui/core/Button';
import MuiIconButton from '@material-ui/core/IconButton';
import { withStyles } from '@material-ui/core/styles';

const Button = (props) => (
  <MuiButton variant="outlined" disableRipple size="small" {...props} />
);

export default withStyles((theme) => ({
  label: {
    textTransform: 'none',
  },
  sizeSmall: {
    padding: `2px ${theme.spacing(1)}px 0 ${theme.spacing(1)}px`,
  },
}))(Button);

const IconButton = withStyles((theme) => ({
  root: {
    padding: theme.spacing(0.5),
    borderRadius: '10%',
  },
}))(({ classes, ...props }) => (
  <MuiIconButton
    classes={{
      root: classes.root,
    }}
    disableRipple
    {...props}
  />
));

export { IconButton };
