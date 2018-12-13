import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import CardHeader from '@material-ui/core/CardHeader';
import Grid from '@material-ui/core/Grid';

class Sequence extends React.Component {

  featureClassName = (featureType) => (`${featureType}Feature`);

  render() {
    const {
      classes,
      title,
      strand,
      sequence,
      features,
      featureLabelMap = {},
      showLegend = true,
    } = this.props;
    return (
      <Card elevation="0">
        <CardContent>
          <div>{title} | {strand}</div>
          <Grid container spacing={24}>
            {
              showLegend ? <Grid item xs={12} md={3} className={classes.legendArea}>
                {
                  [...new Set(features.map(({type: featureType}) => (featureType)))].map(
                    (featureType) => {
                      return (
                        <span className={classes[this.featureClassName(featureType)] + ' ' + classes.featureLegendItem}>
                          {featureLabelMap[featureType] || featureType} <br />
                        </span>
                      )
                    }
                  )
                }
              </Grid> : null
            }
            <Grid item xs={1}>
              <div><span>101</span></div>
            </Grid>
            <Grid item className={classes.fastaText}>
              > {title}
              <p className={classes.sequenceText}>
                {
                  sequence.split('').map((letter, index) => {
                    const featureClasses = features.filter((feature) => {
                      return feature.start <= (index + 1) && feature.stop >= (index + 1);
                    }).map(
                      ({type: featureType}) => classes[this.featureClassName(featureType)]
                    );
                    return (<span className={classes.sequenceChar + ' ' + featureClasses.join(' ')} key={index}>{letter}</span>);
                  })
                }
              </p>
            </Grid>
          </Grid>
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
  fastaText: {
    fontFamily: 'monospace',
    fontSize: '10pt',
  },
  sequenceText: {
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
    backgroundColor: '#FF8080',
    textTransform: 'uppercase',
  },
  featureLegendItem: {
    textTransform: 'unset',
  },
  legendArea: {
    [theme.breakpoints.up('md')]: {
      order: 4,
    },
  },
});

export default withStyles(styles)(Sequence);