import React from 'react';
import PropTypes from 'prop-types';
import ErrorBoundary from './ErrorBoundary';
import ThemeProvider from './ThemeProvider';

export default function Root({ children }) {
  return (
    <ThemeProvider>
      <ErrorBoundary>{children}</ErrorBoundary>
    </ThemeProvider>
  );
}

Root.propTypes = {
  children: PropTypes.any,
};

Root.displayName = 'Root';
