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

const IconButton = (props) => <MuiIconButton disableRipple {...props} />;

export {
  IconButton
};
