import React from 'react';
import { createMuiTheme, MuiThemeProvider, withStyles } from '@material-ui/core/styles';
import deepPurple from '@material-ui/core/colors/deepPurple';
import blueGrey from '@material-ui/core/colors/blueGrey';
import red from '@material-ui/core/colors/red';

const wormbaseTheme = createMuiTheme({
  palette: {
    primary: blueGrey,
    secondary: {
      ...deepPurple
    },
    error: red,
  },
});

const ThemeProvider = ({children, ...props}) => (
  <MuiThemeProvider theme={wormbaseTheme} {...props}>
    {children}
  </MuiThemeProvider>
);

export default ThemeProvider;

export {
  withStyles
};
