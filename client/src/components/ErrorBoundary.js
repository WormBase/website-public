import React from 'react';
import PropTypes from 'prop-types';
import ErrorMessage from './ErrorMessage';

export default class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true, error };
  }

  componentDidCatch(error, info) {
    // You can also log the error to an error reporting service
    // logErrorToMyService(error, info);
    // console.log(error)
    // console.log(info);
  }

  render() {
    if (this.state.hasError) {
      // You can render any custom fallback UI
      return <ErrorMessage error={this.state.error} />;
    }

    return this.props.children;
  }
}

ErrorBoundary.propTypes = {
  children: PropTypes.any,
};
