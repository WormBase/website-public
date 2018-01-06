import React from 'react';
import MuiButton from 'material-ui/Button';
import MuiIconButton from 'material-ui/IconButton';
import { withStyles } from 'material-ui/styles';

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
