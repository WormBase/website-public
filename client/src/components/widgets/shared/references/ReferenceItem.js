import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from 'material-ui/styles';
import classNames from 'classnames';
import Link from '../../../Link';

class ReferenceItem extends Component {
  static propTypes = {
    classes: PropTypes.object.isRequired,
    data: PropTypes.shape({
      name: PropTypes.shape({
        id: PropTypes.string.isRequired,
        "class": PropTypes.string.isRequired,
      }).isRequired,
      author: PropTypes.array,
    }),
  };

  render() {
    const {data, classes} = this.props;
    return (
      <div className={classes.referenceItem}>
        <Link
          id={data.name.id} label={data.title[0]} class={data.name.class}
          classes={{
            linkLabel: classes.title,
          }}
        />
        <div>
          {
            data.author.map((tag, index) => (
              <span>
                {index !== 0 ? <span>, </span> : null}
                <Link {...tag} class="person" key={tag.id} />
              </span>
            ))
          }
        </div>
        <div>
          [{data.journal[0]}, {data.year}]
        </div>
        <div className={classNames([classes.abstract, classes.fade])}>
          <p>{data.abstract[0]}</p>
        </div>
      </div>
    );
  }
}

const styles = (theme) => ({
  referenceItem: {
    paddingTop: theme.spacing.unit / 2,

  },
  title: {
    textDecoration: 'underline',
  },
  abstract: {
    height: '3.8em',
    overflow: 'hidden',
  },
  fade: {
    position: 'relative',
    "&:after": {
      content: '""',
      textAlign: 'right',
      position: 'absolute',
      bottom: 0,
      left: 0,
      width: '100%',
      height: '1.5em',
      background: 'linear-gradient(to bottom, transparent, rgba(255,255,255, 0.7))',
    },
  },
});

export default withStyles(styles, {withTheme: true})(ReferenceItem);
