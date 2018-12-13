import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import CardHeader from '@material-ui/core/CardHeader';
import Grid from '@material-ui/core/Grid';
import Hidden from '@material-ui/core/Hidden';

class Sequence extends React.Component {

  featureClassName = (featureType) => (`${featureType}Feature`);

  renderLineNumbers = (numberLettersPerLine) => {
    const {classes, sequence} = this.props;
    return (
      <p className={classes.lineNumbers + ' ' + classes.fastaText}>
        {
          sequence.match(new RegExp(`.{1,${numberLettersPerLine}}`, 'g')).map((_, index) => (
            <span>{index * numberLettersPerLine + 1}<br /></span>
          ))
        }
      </p>
    );
  }

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
          <Grid container spacing={0}>
            {
              showLegend ? <Grid item xs={12} md={2} className={classes.legendArea}>
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
            <Hidden mdUp>
              <Grid item xs={1} className={classes.lineNumberArea}>
                {this.renderLineNumbers(20)}
              </Grid>
            </Hidden>
            <Hidden smDown>
              <Grid item md={1} className={classes.lineNumberArea}>
                {this.renderLineNumbers(50)}
              </Grid>
            </Hidden>
            <Grid item className={classes.fastaText + ' ' + classes.fastaTextArea}>
              <span className={classes.fastaHeaderText}>> {title}</span>
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
  fastaHeaderText: {
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
  fastaTextArea: {
    flex: '0 1 0',
  },
  lineNumberArea: {
    position: 'relative',
  },
  lineNumbers: {
    position: 'absolute',
    bottom: 0,
    right: 0,
    paddingRight: theme.spacing.unit * 2,
    textAlign: 'end',
  },
});

export default withStyles(styles)(Sequence);