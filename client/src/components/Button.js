import React from 'react';
import MuiButton from '@material-ui/core/Button';
import MuiIconButton from '@material-ui/core/IconButton';
import { withStyles } from '@material-ui/core/styles';

const Button = (props) => (
  <MuiButton disableRipple {...props} />
);

export default withStyles({
  label: {
    textTransform: 'none',
  },
})(Button);

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
