import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CheckmarkIcon from '@material-ui/icons/Done';
import SaveIcon from '@material-ui/icons/Save';
import CopyIcon from '@material-ui/icons/FileCopy';
import ExpandMoreIcon from '@material-ui/icons/ArrowRight';
import ExpandLessIcon from '@material-ui/icons/ArrowDropDown';
import Sequence from './Sequence';
import DownloadButton from '../DownloadButton';
import { CopyToClipboard } from 'react-copy-to-clipboard';
import Button, { IconButton } from '../Button';
import CardActionArea from '../CardActionArea';
import Tooltip from '../Tooltip';


const  SequenceCard = (props) => {

  const {
    classes,
    className,
    sequence = '',
    title = 'Sequence',
    downloadFileName = 'sequence.fasta',
    initialExpand = true,
    ...sequenceProps,
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
          <CardActionArea className={classes.expandToggleAction} onClick={() => setExpand(!expand)}>

            {
              expand ? <ExpandLessIcon /> : <ExpandMoreIcon />
            }

            <h5 className={classes.title}>{title}</h5>
          </CardActionArea>
        </Tooltip>
        <Tooltip title="Save to file">
          <DownloadButton
            fileName={downloadFileName}
            renderer={(props) => (
              <Button variant="outlined" {...props}>
                Download
                <SaveIcon className={classes.buttonIcon} />
              </Button>
            )}
            contentFunc={() => `> ${title}\r\n${sequence}` }
          />
        </Tooltip>
        <CopyToClipboard
          text={`> ${title}\r\n${sequence}`}
          onCopy={() => setCopied(true)}
        >
          <Tooltip title="Copy to clipboard">
            <Button variant="outlined">
              Copy <CopyIcon className={classes.buttonIcon} />
              { copied ? <CheckmarkIcon className={classes.buttonIcon} /> : null }
            </Button>
          </Tooltip>
        </CopyToClipboard>
      </CardActions>
      {
        expand ? <Sequence title={title} sequence={sequence} {...sequenceProps} /> : null
      }
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
    [theme.breakpoints.down('xs')]: {
      flexWrap: 'wrap',
    },
    alignItems: 'stretch',
  },
  expandToggleAction: {
    display: 'flex',
    justifyContent: 'start',
    width: 'initial',
    paddingRight: theme.spacing.unit,
    flex: '1 0 auto',
    [theme.breakpoints.down('xs')]: {
      width: '100%',
    },
    // border: `1px solid #eee`,
    // backgroundColor: theme.palette.grey[200],
  },
  title: {
    fontSize: '0.9em',
  },
  buttonIcon: {
    marginLeft: theme.spacing.unit / 2,
  }
});

export default withStyles(styles)(SequenceCard);
