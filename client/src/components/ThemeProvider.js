import React from 'react';
import {
  createMuiTheme,
  MuiThemeProvider,
  withStyles,
} from '@material-ui/core/styles';
import {
  deepPurple as secondaryColor,
  blueGrey as primaryColor,
  red as errorColor,
} from '@material-ui/core/colors';

const wormbaseTheme = createMuiTheme({
  palette: {
    primary: primaryColor,
    secondary: {
      ...secondaryColor,
    },
    error: errorColor,
  },
});

const ThemeProvider = ({ children, ...props }) => (
  <MuiThemeProvider theme={wormbaseTheme} {...props}>
    {children}
  </MuiThemeProvider>
);

export default ThemeProvider;

export { withStyles };
