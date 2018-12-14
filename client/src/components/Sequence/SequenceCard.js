import React from 'react';
import PropTypes from 'prop-types';
import { withStyles } from '@material-ui/core/styles';
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import CardHeader from '@material-ui/core/CardHeader';
import Sequence from './Sequence';

class SequenceCard extends React.Component {
  render() {
    const {
      title = 'Sequence',
      ...sequenceProps,
    } = this.props;
    return (
      <Card elevation="0">
        <CardContent>
          <div>{title}</div>
          <Sequence title={title} {...sequenceProps} />
        </CardContent>
      </Card>
    );
  }
}

SequenceCard.propTypes = {
  title: PropTypes.string,
};

const styles = (theme) => ({});

export default withStyles(styles)(SequenceCard);