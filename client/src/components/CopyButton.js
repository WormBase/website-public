import React, { useState, useEffect, useCallback } from 'react';
import copy from 'copy-to-clipboard';
import { withStyles } from '@material-ui/core/styles';
import CheckmarkIcon from '@material-ui/icons/Done';
import CopyIcon from '@material-ui/icons/FileCopy';
import Button from './Button';
import Tooltip from './Tooltip';

function CopyButton({ classes, text, textFunc }) {
  const [copied, setCopied] = useState(false);

  const handleClick = useCallback(() => {
    new Promise((resolve) => {
      if (text) {
        resolve(text);
      } else {
        resolve(textFunc ? textFunc() : '');
      }
    }).then((resolvedText) => {
      copy(resolvedText);
      setCopied(true);
    });
  }, [text, textFunc]);

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
    <Tooltip title="Copy to clipboard">
      <Button
        variant="outlined"
        className={classes.button}
        onClick={handleClick}
      >
        Copy <CopyIcon className={classes.buttonIcon} fontSize="inherit" />
        {copied ? (
          <CheckmarkIcon className={classes.buttonIcon} fontSize="inherit" />
        ) : null}
      </Button>
    </Tooltip>
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
    marginLeft: theme.spacing(0.5),
  },
});

export default withStyles(styles)(CopyButton);
