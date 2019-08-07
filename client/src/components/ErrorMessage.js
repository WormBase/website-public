import React from 'react';
import { withStyles } from '@material-ui/core/styles';
import classNames from 'classnames';

import Card from '@material-ui/core/Card';
import CardContent from '@material-ui/core/CardContent';
import Typography from '@material-ui/core/Typography';

function ErrorMessage({
  classes,
  classNameProp,
  title = 'Sorry, a problem occurred.',
}) {
  const className = classNames(classes.root, classNameProp);
  return (
    <Card className={className}>
      <CardContent>
        <Typography variant="h6" className={classes.title} gutterBottom>
          {title}
        </Typography>
        <Typography component="h2">
          Please help us address the problem by emailing{' '}
          <a href="mailto:help@wormbase.org">help@wormbase.org</a>.
        </Typography>
      </CardContent>
    </Card>
  );
}

const styles = (theme) => ({
  root: {},
  title: {
    color: theme.palette.error.light,
  },
});

export default withStyles(styles)(ErrorMessage);
