import React from 'react';
import PropTypes from 'prop-types';
import { makeStyles } from '@material-ui/core/styles';
import { hasContent } from '../util/hasContent';
import SimpleCell from './SimpleCell';

const useStyles = makeStyles(() => ({
  root: {
    margin: 0,
  },
}));

const HashCell = ({ data, render }) => {
  const classes = useStyles();

  if (data.species) {
    return <SimpleCell data={`${data.genus}. ${data.species}`} />;
  }
  return (
    <dl className={classes.root}>
      {Object.keys(data)
        .filter((key) => hasContent(data[key]))
        .map((key) => (
          <>
            <dt key={key}>{key.replace(/_+/g, ' ')}:</dt>
            <dd>{render({ elementValue: data[key] })}</dd>
          </>
        ))}
    </dl>
  );
};

HashCell.propTypes = {
  data: PropTypes.object,
  render: PropTypes.func.isRequired,
};

export default HashCell;
