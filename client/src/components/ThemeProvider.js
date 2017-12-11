import React from 'react';
import { createMuiTheme, MuiThemeProvider, withStyles } from 'material-ui/styles';
import deepPurple from 'material-ui/colors/deepPurple';
import blueGrey from 'material-ui/colors/blueGrey';
import red from 'material-ui/colors/red';

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
