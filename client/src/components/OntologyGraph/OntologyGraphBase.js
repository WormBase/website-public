import React, { useRef, useEffect } from 'react';
import PropTypes from 'prop-types';
import ResponsiveDrawer from '../ResponsiveDrawer';
import Button from '../Button';
import { CircularProgress } from '../Progress';
import Loading from '../Loading';
import ErrorMessage from '../ErrorMessage';

import { withStyles } from '@material-ui/core/styles';
import MoreIcon from '@material-ui/icons/MoreVert';
import HelpIcon from '@material-ui/icons/Help';
import LockIcon from '@material-ui/icons/Lock';
import LockOpenIcon from '@material-ui/icons/LockOpen';
import RefreshIcon from '@material-ui/icons/Refresh';
import SaveIcon from '@material-ui/icons/Save';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import Radio from '@material-ui/core/Radio';
import RadioGroup from '@material-ui/core/RadioGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import FormControl from '@material-ui/core/FormControl';
import FormHelperText from '@material-ui/core/FormHelperText';
import Tooltip from '@material-ui/core/Tooltip';

import classNames from 'classnames';
import { useInView } from 'react-intersection-observer';

import useOntologyGraph from './useOntologyGraph';

function OntologyGraphBase({
  useOntologyGraphParams = {},
  renderCustomSidebar,
  classes,
}) {
  const [containerWrapperRef, inView] = useInView({
    //triggerOnce: true,
  });
  const [state, dispatch, containerElement] = useOntologyGraph({
    ...useOntologyGraphParams,
  });

  useEffect(() => {
    if (inView) {
      dispatch({ type: 'start_render' });
    }
  }, [inView]);

  const { datatype, focusTermId } = useOntologyGraphParams;
  const {
    loading,
    error,
    data,
    meta,
    depthRestriction,
    isWeighted,
    isLocked,
    // et, // only used in custom portion of the sidebar
    save,
  } = state;

  const graphSidebar = data.length ? (
    <div className={classes.sidebar}>
      <FormControl component="fieldset">
        <RadioGroup
          aria-label="weighted"
          name="weighted"
          value={isWeighted ? 'weighted' : 'unweighted'}
          onChange={(event) =>
            dispatch({
              type: 'set_weighted',
              payload: event.target.value === 'weighted',
            })
          }
          row
        >
          <FormControlLabel
            value="weighted"
            control={<Radio />}
            label="Weighted"
          />
          <FormControlLabel
            value="unweighted"
            control={<Radio />}
            label="Uniform"
          />
        </RadioGroup>
        <FormHelperText>
          "Weighted" configuration sets the size of nodes proportional to the
          number of annotations
        </FormHelperText>
      </FormControl>
      <TextField
        select
        label={<span>Graph depth</span>}
        value={depthRestriction}
        onChange={(event) =>
          dispatch({
            type: 'set_max_depth',
            payload: event.target.value,
          })
        }
      >
        {Array(Math.max(depthRestriction, meta.fullDepth) + 1)
          .fill(1)
          .map((_, index) => {
            return (
              <MenuItem
                key={index}
                value={index}
                disabled={index > meta.fullDepth}
              >
                {index === 0 ? 'Maximum depth' : index}
              </MenuItem>
            );
          })}
      </TextField>
      {renderCustomSidebar && renderCustomSidebar({ state, dispatch })}
    </div>
  ) : null;
  const graphView = (
    <div
      className={classNames(classes.cytoscapeContainer, {
        [classes.cytoscapeContainerLoading]: loading,
      })}
    >
      {error ? (
        <ErrorMessage />
      ) : (
        <div ref={containerElement} className={classes.cytoscapeElement} />
      )}
      {loading ? <Loading center /> : null}
    </div>
  );

  const drawerRef = useRef();
  const graphToolbar = (
    <div className={classes.toolbar}>
      <Tooltip title="If unlocked, mouse scroll wheel allows zooming in on the graph.">
        <Button
          variant={isLocked ? 'contained' : 'outlined'}
          color={isLocked ? 'primary' : 'text'}
          onClick={() => dispatch({ type: 'set_lock_toggle' })}
        >
          <span className={classes.buttonTextLabel}>Scroll wheel zoom</span>
          {isLocked ? <LockIcon /> : <LockOpenIcon />}
        </Button>
      </Tooltip>
      <Button variant={'outlined'} onClick={() => dispatch({ type: 'reset' })}>
        <span className={classes.buttonTextLabel}>Reset</span> <RefreshIcon />
      </Button>
      <div className={classes.stretch} />
      <Button
        variant="outlined"
        disabled={save === 'pending'}
        onClick={() =>
          dispatch({
            type: 'save_image_requested',
            payload: `${datatype}_soba_${focusTermId}.png`,
          })
        }
      >
        <span className={classes.buttonTextLabel}>Save image</span>
        {save === 'pending' ? <CircularProgress size={20} /> : <SaveIcon />}
      </Button>
      <Button
        className={classes.buttonMore}
        variant="outlined"
        onClick={() =>
          drawerRef.current && drawerRef.current.handleDrawerToggle()
        }
      >
        <span className={classes.buttonTextLabel}>Options</span>
        <MoreIcon />
      </Button>
      <Button
        className={classes.linkHelp}
        variant="outlined"
        component="a"
        target="_blank"
        href="http://wiki.wormbase.org/index.php/User_Guide/SObA"
      >
        <HelpIcon />
      </Button>
    </div>
  );

  return (
    <ResponsiveDrawer
      rootRef={containerWrapperRef}
      innerRef={drawerRef}
      anchor="right"
      drawerContent={graphSidebar}
      mainContent={graphView}
      mainHeader={graphToolbar}
    />
  );
}

OntologyGraphBase.propTypes = {
  useOntologyGraphParams: PropTypes.object,
  renderCustomSidebar: PropTypes.func,
};

OntologyGraphBase.displayName = 'OntologyGraphBase';

const styles = (theme) => ({
  /* toolbar and buttons */
  toolbar: {
    padding: theme.spacing.unit,
    display: 'flex',
    '& > *': {
      margin: `0 ${theme.spacing.unit / 2}px`,
    },
  },
  stretch: {
    flex: '1 1 auto',
    margin: 0,
  },
  buttonMore: {
    [theme.breakpoints.up('md')]: {
      display: 'none',
    },
  },
  linkHelp: {
    color: '#000',
    '&:link': {
      color: theme.palette.text.primary,
    },
    '&:visited': {
      color: theme.palette.text.primary,
    },
  },
  buttonTextLabel: {
    display: 'none',
    [theme.breakpoints.up('md')]: {
      display: 'inline',
    },
  },

  /* container for cytoscape view */

  cytoscapeContainer: {
    position: 'relative',
    height: '100%',
    width: '100%',
    boxSizing: 'border-box',
    // border: 'solid 1px gray',
    overflow: 'hidden',
  },
  cytoscapeElement: {
    height: '100%',
    width: '100%',
  },
  cytoscapeContainerLoading: {
    opacity: 0.3,
  },

  /* sidebar */
  sidebar: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'stretch',
    '& > *': {
      margin: `${theme.spacing.unit * 2}px ${theme.spacing.unit * 2}px`,
    },
  },
});

export default withStyles(styles)(OntologyGraphBase);
