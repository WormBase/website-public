import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Grid from '@material-ui/core/Grid';
import Hidden from '@material-ui/core/Hidden';

class Sequence extends React.Component {
  featureClassName = (featureType) => `${featureType}Feature`;

  renderLineNumbers = (numberLettersPerLine) => {
    const { classes, sequence } = this.props;
    return (
      <p className={classes.lineNumbers + ' ' + classes.fastaText}>
        {sequence
          .match(new RegExp(`.{1,${numberLettersPerLine}}`, 'g'))
          .map((_, index) => (
            <span key={index}>
              {index * numberLettersPerLine + 1}
              <br />
            </span>
          ))}
      </p>
    );
  };

  render() {
    const {
      classes,
      title,
      sequence,
      features = [],
      featureLabelMap = {},
      showLegend = true,
    } = this.props;
    return sequence ? (
      <Grid container spacing={0} className={classes.root}>
        {showLegend && features.length ? (
          <Grid item xs={12} md={2} className={classes.legendArea}>
            <span>
              <em>Legends</em>
            </span>
            {[
              ...new Set(features.map(({ type: featureType }) => featureType)),
            ].map((featureType) => {
              return (
                <p key={featureType} className={classes.featureLegendItem}>
                  <span
                    className={
                      classes[this.featureClassName(featureType)] +
                      ' ' +
                      classes.featureLegendItemSymbol
                    }
                  >
                    &nbsp;a&nbsp;
                  </span>{' '}
                  {featureLabelMap[featureType] || featureType}
                </p>
              );
            })}
          </Grid>
        ) : null}
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
            {sequence.split('').map((letter, index) => {
              const featureClasses = features
                .filter((feature) => {
                  return (
                    feature.start <= index + 1 && feature.stop >= index + 1
                  );
                })
                .map(
                  ({ type: featureType }) =>
                    classes[this.featureClassName(featureType)]
                );
              return (
                <span
                  key={index}
                  className={
                    classes.sequenceChar + ' ' + featureClasses.join(' ')
                  }
                >
                  {letter}
                </span>
              );
            })}
          </p>
        </Grid>
      </Grid>
    ) : null;
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
    })
  ),
};

const styles = (theme) => ({
  root: {
    '& div': {
      paddingLeft: theme.spacing.unit * 1.5,
      maxHeight: 1000000 /* prevent font boosting that sets line number and sequence to different computed font-size*/,
    },
  },
  fastaText: {
    fontFamily: 'monospace',
    fontSize: '10pt',
  },
  fastaHeaderText: {},
  sequenceText: {
    '& span:nth-child(10n)': {
      marginRight: '0.5em',
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
  exon_0Feature: {
    backgroundColor: 'yellow',
    textTransform: 'uppercase',
  },
  exon_1Feature: {
    backgroundColor: 'orange',
    textTransform: 'uppercase',
  },
  intronFeature: {},
  UTRFeature: {
    textTransform: 'lowercase',
    backgroundColor: '#ccc',
  },
  paddingFeature: {
    backgroundColor: 'beige',
  },
  flankFeature: {
    backgroundColor: 'yellow',
  },
  featureFeature: {
    backgroundColor: 'yellow',
  },
  variationFeature: {
    backgroundColor: '#FF8080',
    textTransform: 'uppercase',
  },
  cgh_flanking_probeFeature: {
    backgroundColor: '#80FFFF',
  },
  cgh_deleted_probeFeature: {
    backgroundColor: '#FFAA54',
    textTransform: 'uppercase',
  },
  featureLegendItem: {
    margin: `${theme.spacing.unit / 2}px 0`,
  },
  featureLegendItemSymbol: {
    // textTransform: 'unset',
    border: `solid 1px ${theme.palette.grey[300]}`,
  },
  legendArea: {
    // color: theme.palette.text.hint,
    color: '#222',
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
    textAlign: 'end',
    color: theme.palette.text.hint,
  },
});

export default withStyles(styles)(Sequence);
