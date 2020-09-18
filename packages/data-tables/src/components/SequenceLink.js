import React, { useState, useCallback } from 'react';
import PropTypes from 'prop-types';
import Button from '@material-ui/core/Button';
import { makeStyles } from '@material-ui/core/styles';
import WidgetDialog from './WidgetDialog';

const useStyles = makeStyles((theme) => ({
  button: {
    marginLeft: -5,
  },
}));

const SequenceLink = ({ id, label, class: type }) => {
  const [isOpen, setOpen] = useState(false);

  const handleOpen = useCallback(() => {
    setOpen(true);
  }, [setOpen]);

  const handleClose = useCallback(() => {
    setOpen(false);
  }, [setOpen]);

  const classes = useStyles();

  return (
    <div>
      <Button className={classes.button} size="small" onClick={handleOpen}>
        sequence
      </Button>
      {id && type ? (
        <WidgetDialog
          open={isOpen}
          onClose={handleClose}
          url={`/rest/widget/${type}/${id}/sequences`}
          title={`${label} sequence`}
        />
      ) : null}
    </div>
  );
};

SequenceLink.propTypes = {
  id: PropTypes.string,
  label: PropTypes.string,
  class: PropTypes.string,
};

export default SequenceLink;
