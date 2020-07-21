import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import SaveIcon from '@material-ui/icons/Save';
import ExpandMoreIcon from '@material-ui/icons/ArrowRight';
import ExpandLessIcon from '@material-ui/icons/ArrowDropDown';
import Sequence from './Sequence';
import Button from '../Button';
import CopyButton from '../CopyButton';
import DownloadButton from '../DownloadButton';
import CardActionArea from '../CardActionArea';
import Tooltip from '../Tooltip';

const SequenceCard = (props) => {
  const {
    classes,
    className,
    sequence = '',
    title = 'Sequence',
    downloadFileName = 'sequence.fasta',
    initialExpand = true,
    ...sequenceProps
  } = props;

  const [expand, setExpand] = useState(initialExpand);
  const [copied, setCopied] = useState(false);

  useEffect(() => {
    if (copied) {
      const timer = setTimeout(() => {
        setCopied(false);
      }, 2000);
      return () => {
        clearTimeout(timer);
        setCopied(false);
      };
    }
    return () => {};
  }, [copied]);

  return sequence ? (
    <Card elevation={0} className={className}>
      <CardActions className={classes.actions}>
        <Tooltip title={expand ? 'Hide sequence' : 'Show sequence'}>
          <CardActionArea
            className={classes.expandToggleAction}
            onClick={() => setExpand(!expand)}
          >
            {expand ? <ExpandLessIcon /> : <ExpandMoreIcon />}

            <h5 className={classes.title}>{title}</h5>
          </CardActionArea>
        </Tooltip>
        <Tooltip title="Save to file">
          <DownloadButton
            fileName={downloadFileName}
            renderer={(props) => (
              <Button variant="outlined" {...props} className={classes.button}>
                Download
                <SaveIcon className={classes.buttonIcon} fontSize="inherit" />
              </Button>
            )}
            contentFunc={() => `>${title}\r\n${sequence}`}
          />
        </Tooltip>
        <CopyButton text={`>${title}\r\n${sequence}`} />
      </CardActions>
      {expand ? (
        <Sequence title={title} sequence={sequence} {...sequenceProps} />
      ) : null}
    </Card>
  ) : null;
};

SequenceCard.propTypes = {
  classes: PropTypes.object.isRequired,
  title: PropTypes.string,
  downloadFileName: PropTypes.string,
};

const styles = (theme) => ({
  actions: {
    display: 'flex',
    [theme.breakpoints.down('sm')]: {
      flexWrap: 'wrap',
    },
    alignItems: 'stretch',
    '& > *': {
      margin: `0 ${theme.spacing.unit / 2}px`,
    },
  },
  expandToggleAction: {
    display: 'flex',
    justifyContent: 'start',
    width: 'initial',
    paddingRight: theme.spacing.unit,
    flex: '1 1 auto',
    [theme.breakpoints.down('sm')]: {
      width: '100%',
      marginBottom: theme.spacing.unit / 2,
    },
    border: `1px solid rgba(0, 0, 0, 0.23)`,
    // backgroundColor: theme.palette.grey[200],
  },
  title: {
    fontSize: '0.9em',
  },
  button: {
    //    padding: `0 ${theme.spacing.unit / 2}px`,
    [theme.breakpoints.down('sm')]: {
      flex: '1 1 auto',
    },
    minWidth: 95,
  },
  buttonIcon: {
    marginLeft: theme.spacing.unit / 2,
  },
});

export default withStyles(styles)(SequenceCard);
