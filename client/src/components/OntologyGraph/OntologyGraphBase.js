import React, { useRef } from 'react';
import PropTypes from 'prop-types';
import ResponsiveDrawer from '../ResponsiveDrawer';
import Button from '../Button';
import Loading from '../Loading';
import ThemeProvider from '../ThemeProvider';

import { withStyles } from '@material-ui/core/styles';
import MoreIcon from '@material-ui/icons/MoreVert';
import TextField from '@material-ui/core/TextField';
import MenuItem from '@material-ui/core/MenuItem';
import Radio from '@material-ui/core/Radio';
import RadioGroup from '@material-ui/core/RadioGroup';
import FormControlLabel from '@material-ui/core/FormControlLabel';
import FormControl from '@material-ui/core/FormControl';
import FormLabel from '@material-ui/core/FormLabel';
import FormHelperText from '@material-ui/core/FormHelperText';
import classNames from 'classnames';

import useOntologyGraph from './useOntologyGraph';

function OntologyGraphBase({
  useOntologyGraphParams = {},
  renderCustomSidebar,
  classes,
}) {
  const [state, dispatch, containerElement] = useOntologyGraph({
    ...useOntologyGraphParams,
  });

  const { loading, error, data, isWeighted, mode, imgSrc, etp } = state;

  const graphSidebar = data ? (
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
        label="Graph depth"
        value={state.depthRestriction || data.meta.fullDepth}
        onChange={(event) =>
          dispatch({
            type: 'set_max_depth',
            payload: event.target.value,
          })
        }
      >
        {Array(data.meta.fullDepth)
          .fill(1)
          .map((_, index) => (
            <MenuItem key={index} value={index + 1}>
              {index + 1}
            </MenuItem>
          ))}
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
      <div ref={containerElement} className={classes.cytoscapeElement} />
      {loading ? <Loading center /> : error ? 'An error occured' : null}
    </div>
  );

  const drawerRef = useRef();
  const graphToolbar = (
    <div className={classes.toolbar}>
      <div className={classes.stretch} />
      <Button
        className={classes.buttonMore}
        variant="outlined"
        onClick={() =>
          drawerRef.current && drawerRef.current.handleDrawerToggle()
        }
      >
        {' '}
        Options
        <MoreIcon />
      </Button>
    </div>
  );

  return (
    <ThemeProvider>
      <ResponsiveDrawer
        innerRef={drawerRef}
        anchor="right"
        drawerContent={graphSidebar}
        mainContent={graphView}
        mainHeader={graphToolbar}
      />
    </ThemeProvider>
  );
}

OntologyGraphBase.propTypes = {
  useOntologyGraphParams: PropTypes.object,
  renderCustomSidebar: PropTypes.func,
};

const styles = (theme) => ({
  /* toolbar and buttons */
  toolbar: {
    padding: theme.spacing.unit,
    display: 'flex',
  },
  stretch: {
    flex: '1 1 auto',
  },
  buttonMore: {
    paddingRight: 0,
    [theme.breakpoints.up('md')]: {
      display: 'none',
    },
  },

  /* container for cytoscape view */

  cytoscapeContainer: {
    position: 'relative',
    height: '100%',
    width: '100%',
    boxSizing: 'border-box',
    border: 'solid 1px gray',
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
