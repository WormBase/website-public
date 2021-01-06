import React from 'react';
import { withStyles } from '@material-ui/core/styles';
import classNames from 'classnames';
import Button from './Button';

import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import CardActions from '@material-ui/core/CardActions';
import Collapse from '@material-ui/core/Collapse';
import Typography from '@material-ui/core/Typography';

function ErrorMessage({
  classes,
  classNameProp,
  title = 'Sorry, a problem occurred.',
  error = {},
}) {
  const className = classNames(classes.root, classNameProp);

  const [expanded, setExpanded] = React.useState(false);

  const handleExpandClick = () => {
    setExpanded(!expanded);
  };

  const { message: errorMessage } = error;

  const supportUrl =
    `/tools/support?url=${document.location.pathname}` +
    (errorMessage
      ? '&msg=' + encodeURIComponent(errorMessage.replace(/^\s+|\s+$|\n/gm, ''))
      : '');

  return (
    <Card className={className}>
      <CardContent>
        <Typography variant="h5" className={classes.title} gutterBottom>
          {title}
        </Typography>
        <Typography variant="h6" gutterBottom>
          We have been notified!
        </Typography>
        <Typography variant="subtitle1">
          If you&#39;d like us to contact you when the issue is fixed, please{' '}
          <a href={supportUrl}>leave us your contact information</a> and we will
          get back to you.
        </Typography>
      </CardContent>
      <CardActions>
        <Button
          className={classes.expandToggleButton}
          onClick={handleExpandClick}
          variant="text"
        >
          Error details
        </Button>
      </CardActions>
      <Collapse in={expanded} timeout="auto" unmountOnExit>
        <CardContent>
          <span dangerouslySetInnerHTML={{ __html: errorMessage }} />
        </CardContent>
      </Collapse>
    </Card>
  );
}

ErrorMessage.displayName = 'ErrorMessage';

const styles = (theme) => ({
  root: {},
  title: {
    //color: theme.palette.error.light,
  },
  error: {
    font: 'monospace',
  },
  expandToggleButton: {},
});

export default withStyles(styles)(ErrorMessage);
