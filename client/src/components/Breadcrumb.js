import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import { buildUrl } from './Link';

class Breadcrumb extends React.Component {
  render() {
    return (
      <span>
        {this.props.trail
          .filter((object) => object)
          .map((object, index) => {
            const { label, url } = object;
            const derivedUrl = url || buildUrl(object);
            return [
              index === 0 ? null : ' » ',
              derivedUrl ? (
                <a href={derivedUrl} key={label}>
                  {label}
                </a>
              ) : (
                <span key={label}>{label}</span>
              ),
            ];
          })}
      </span>
    );
  }
}

Breadcrumb.propTypes = {
  trail: PropTypes.arrayOf(
    PropTypes.shape({
      label: PropTypes.string.isRequired,
      url: PropTypes.string,
    })
  ),
};

const styles = (theme) => ({
  root: {},
});

export default withStyles(styles)(Breadcrumb);
