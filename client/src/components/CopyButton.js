import React, { useState, useEffect } from 'react';
import { CopyToClipboard } from 'react-copy-to-clipboard';
import { withStyles } from '@material-ui/core/styles';
import CheckmarkIcon from '@material-ui/icons/Done';
import CopyIcon from '@material-ui/icons/FileCopy';
import Button from './Button';
import Tooltip from './Tooltip';

function CopyButton({ classes, text }) {
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

  return (
    <CopyToClipboard text={text} onCopy={() => setCopied(true)}>
      <Tooltip title="Copy to clipboard">
        <Button variant="outlined" className={classes.button}>
          Copy <CopyIcon className={classes.buttonIcon} fontSize="inherit" />
          {copied ? (
            <CheckmarkIcon className={classes.buttonIcon} fontSize="inherit" />
          ) : null}
        </Button>
      </Tooltip>
    </CopyToClipboard>
  );
}

const styles = (theme) => ({
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

export default withStyles(styles)(CopyButton);
