import React from 'react';
import {
  createMuiTheme,
  MuiThemeProvider,
  withStyles,
} from '@material-ui/core/styles';
import secondaryColor from '@material-ui/core/colors/deepPurple';
import primaryColor from '@material-ui/core/colors/blueGrey';
import errorColor from '@material-ui/core/colors/red';

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
