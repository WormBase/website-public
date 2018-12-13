import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import CardHeader from '@material-ui/core/CardHeader';

class Sequence extends React.Component {
  render() {
    const {classes, title, strand, sequence, features} = this.props;
    return (
      <Card elevation="0">
        <CardContent>
          {title} | {strand}
          <p className={classes.sequenceText}>
            {
              sequence.split('').map((letter, index) => {
                const featureClasses = features.filter((feature) => {
                  return feature.start <= (index + 1) && feature.stop >= (index + 1);
                }).map(
                  (feature) => classes[`${feature.type}Feature`]
                );
                return (<span className={featureClasses.join(' ')} key={index}>{letter}</span>);
              })
            }
          </p>
        </CardContent>
      </Card>
    )
  }
}

Sequence.propTypes = {
  classes: PropTypes.object.isRequired,
  title: PropTypes.string,
  sequence: PropTypes.string,
  features: PropTypes.arrayOf(
    PropTypes.shape({
      type: PropTypes.string,
      start: PropTypes.number,
      stop: PropTypes.number,
    }),
  ),
  strand: PropTypes.oneOf(['+', '-']),
};

const styles = (theme) => ({
  sequenceText: {
    fontFamily: 'monospace',
    fontSize: '10pt',
    textTransform: 'lowercase',
    '& span:nth-child(10n)': {
      marginRight: '1em',
    },
    [theme.breakpoints.down('sm')]: {
      '& span:nth-child(20n+1)': {
        '&:before': {
          content: '""',
          display: 'block',
        },
      },
    },
    [theme.breakpoints.up('md')]: {
      '& span:nth-child(50n+1)': {
        '&:before': {
          content: '""',
          display: 'block',
        },
      },
    },
  },
  flankFeature: {
    backgroundColor: 'yellow',
  },
  variationFeature: {
    backgroundColor: 'red',
    textTransform: 'uppercase',
  },
});

export default withStyles(styles)(Sequence);