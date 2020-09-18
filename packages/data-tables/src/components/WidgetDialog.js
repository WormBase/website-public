import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core/styles';
import Button from '@material-ui/core/Button';
import Dialog from '@material-ui/core/Dialog';
import MuiDialogTitle from '@material-ui/core/DialogTitle';
import DialogContent from '@material-ui/core/DialogContent';
import DialogActions from '@material-ui/core/DialogActions';
import IconButton from '@material-ui/core/IconButton';
import CloseIcon from '@material-ui/icons/Close';
import Typography from '@material-ui/core/Typography';
import CircularProgress from '@material-ui/core/CircularProgress';

const useStyles = makeStyles((theme) => ({
  dialogTitle: {
    margin: 0,
    padding: theme.spacing(2),
  },
  dialogTitleCloseButton: {
    position: 'absolute',
    right: theme.spacing(1),
    top: theme.spacing(1),
    color: theme.palette.grey[500],
  },
}));

const DialogTitle = (props) => {
  const { children, classes, onClose, ...other } = props;
  return (
    <MuiDialogTitle
      disableTypography
      className={classes.dialogTitle}
      {...other}
    >
      <Typography variant="h6">{children}</Typography>
      {onClose ? (
        <IconButton
          aria-label="close"
          className={classes.dialogTitleCloseButton}
          onClick={onClose}
        >
          <CloseIcon />
        </IconButton>
      ) : null}
    </MuiDialogTitle>
  );
};

const WidgetDialog = ({ url, title, open, onClose }) => {
  const [isLoading, setLoading] = useState(true);
  const [html, setHtml] = useState('');
  const [error, setError] = useState(null);

  useEffect(() => {
    // load HTML via ajax
    if (open) {
      fetch(url, {
        headers: {
          Accept: 'text/html',
        },
      })
        .then((response) => {
          if (response.ok) {
            return response.text();
          } else {
            throw new Error('An error has occcured when fetching content.');
          }
        })
        .then((body) => {
          setHtml(body);
          setLoading(false);
        })
        .catch((error) => {
          setError(error.message);
          setLoading(false);
        });
    }
  }, [url, open, setHtml, setError, setLoading]);

  useEffect(() => {
    // execute scripts after HTML injected into DOM
    const re = /<script.*?>((.|\n|\r)+?)<\/script>/gi;
    const scripts = [];
    var match = re.exec(html);

    while (match) {
      scripts.push(match[1]);
      match = re.exec(html);
    }

    scripts.forEach((script) => {
      // eslint-disable-next-line
      window.eval(script);
    });
  });

  const classes = useStyles();

  return (
    <Dialog
      onClose={onClose}
      aria-labelledby="customized-dialog-title"
      open={open}
      fullWidth
      maxWidth="md"
    >
      <DialogTitle
        id="customized-dialog-title"
        onClose={onClose}
        classes={{
          dialogTitle: classes.dialogTitle,
          dialogTitleCloseButton: classes.dialogTitleCloseButton,
        }}
      >
        {title}
      </DialogTitle>
      <DialogContent dividers>
        {isLoading ? (
          <CircularProgress />
        ) : error ? (
          <span>error</span>
        ) : (
          <div dangerouslySetInnerHTML={{ __html: html }} />
        )}
      </DialogContent>
      <DialogActions>
        <Button autoFocus onClick={onClose}>
          Close
        </Button>
      </DialogActions>
    </Dialog>
  );
};

WidgetDialog.propTypes = {
  url: PropTypes.string.isRequired,
  title: PropTypes.any,
  open: PropTypes.bool,
  onClose: PropTypes.func,
};

export default WidgetDialog;
