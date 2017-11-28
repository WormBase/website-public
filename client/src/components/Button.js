import React from 'react';
import MuiButton from 'material-ui/Button';
import { withStyles } from 'material-ui/styles';

const Button = (props) => (
  <MuiButton disableRipple {...props} />
);

export default withStyles({
  label: {
    textTransform: 'none',
  },
})(Button);
