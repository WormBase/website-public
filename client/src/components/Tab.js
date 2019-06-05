import React from 'react';
import MuiTab from '@material-ui/core/Tab';
import { withStyles } from '@material-ui/core/styles';
import { fade } from '@material-ui/core/styles/colorManipulator';

const Tab = (props) => {
  return <MuiTab {...props} disableRipple={true} />;
};

const styles = (theme) => ({
  root: {
    '&:hover': {
      textDecoration: 'none',
      backgroundColor: fade(
        theme.palette.text.primary,
        theme.palette.action.hoverOpacity
      ),
      // Reset on touch devices, it doesn't add specificity
      '@media (hover: none)': {
        backgroundColor: 'transparent',
      },
      '&$disabled': {
        backgroundColor: 'transparent',
      },
    },
  },
});

export default withStyles(styles, { withTheme: true })(Tab);
