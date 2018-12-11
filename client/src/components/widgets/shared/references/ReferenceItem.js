import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import classNames from 'classnames';
import Link from '../../../Link';
import Chip from '../../../Chip';

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

  constructor(props) {
    super(props);
    this.state = {
      expanded: false,
    };
  }

  handleExpandToggle = () => {
    this.setState((prevState) => ({
      expanded: !prevState.expanded,
    }));
  }

  render() {
    const {data, classes} = this.props;
    return (
      <div className={classes.referenceItem}>
        <Link
          id={data.name.id} label={data.title && data.title[0]} class={data.name.class}
          classes={{
            linkLabel: classes.title,
          }}
        />
        <div>
          {
            (data.author || []).map((tag, index) => (
              <span key={tag.id}>
                {index !== 0 ? <span>, </span> : null}
                <Link {...tag} class="person" key={tag.id} />
              </span>
            ))
          }
        </div>
        <div className={classes.chipWrapper}>
          <Chip label={data.ptype} />
          <Chip label={<em>{data.journal && data.journal[0]}</em>} />
          <Chip label={data.year} />
        </div>
        <div
          className={classNames(classes.abstract, classes.fade, {[classes.abstractCollapse]: !this.state.expanded})}
          onClick={() => this.handleExpandToggle() }
        >
          {data.abstract && <p>{data.abstract[0]}</p>}
        </div>
      </div>
    );
  }
}

const styles = (theme) => ({
  referenceItem: {
    margin: `${theme.spacing.unit}px 0px`,

  },
  title: {
    textDecoration: 'underline',
  },
  abstract: {
    overflow: 'hidden',
    cursor: 'pointer',
    borderBottom: '1px solid lightgray',
    '&:hover': {
      backgroundColor: '#E9EEF2',
    },
  },
  abstractCollapse: {
    maxHeight: '3.8em',
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
      height: '1.0em',
      background: 'linear-gradient(to bottom, transparent, rgba(255,255,255, 0.7))',
    },
  },
  chipWrapper: {
    display: 'flex',
    marginLeft: -1 * theme.spacing.unit / 2,
    '& > *': {
      margin: theme.spacing.unit / 2,
      height: theme.spacing.unit * 2.5,
    },
  },
});

export default withStyles(styles, {withTheme: true})(ReferenceItem);
