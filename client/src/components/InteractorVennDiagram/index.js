import React, { useRef, useEffect, useState, useMemo } from 'react';
import PropTypes from 'prop-types';
import Badge from '@material-ui/core/Badge';
import PageViewIcon from '@material-ui/icons/Pageview';
import ClearIcon from '@material-ui/icons/Clear';
import { withStyles } from '@material-ui/core/styles';
import BrowseCollection from '../BrowseCollection';
import Button from '../Button';
import draw from './draw';
import { subsets, isSuperSet } from './utils';
import { capitalize } from '../../utils';

function InteractorVennDiagram({ data: dataRaw = [], classes = {} }) {
  const d3Element = useRef();
  const venn = useRef({});
  const [selections, setSelections] = useState([]);

  const data = useMemo(
    () =>
      dataRaw.map(({ types, ...others }) => ({
        ...others,
        types: types.map((t) => `${capitalize(t)} interactor`),
      })),
    [dataRaw]
  );

  useEffect(() => {
    // draw the venn diagram
    const typeSet = data.reduce((result, { types = [], interactor = {} }) => {
      types.forEach((t) => result.add(t));
      return result;
    }, new Set());

    const vennSubsets = subsets(typeSet).map((s) => {
      return {
        sets: s,
        size: data.filter(({ types: interactorTypes }) =>
          isSuperSet(interactorTypes, s)
        ).length,
      };
    });

    const colorMap = vennSubsets
      .filter((d) => d.sets.length === 1)
      .reduce((result, d) => {
        const colors = {
          'Physical interactor': '#009e73',
          'Genetic interactor': '#6a3d9a',
          'Regulatory interactor': '#ffce3b',
        };
        result[d.sets] = colors[d.sets[0]];
        return result;
      }, {});

    venn.current = draw(
      d3Element.current,
      vennSubsets,
      (key) => colorMap[key] || 'gray',
      {
        onAreaSelectionUpdate: setSelections,
      }
    );
  }, [data, d3Element]);

  const selectedInteractors = useMemo(() => {
    function inIntersection(querySets, sets) {
      return sets.every((qs) => querySets.indexOf(qs) > -1);
    }

    return data
      .filter(({ types }) =>
        selections.some(({ vennArea, intersectedAreas = [] }) => {
          const isSelected = intersectedAreas.reduce(
            (result, { sets: subtractedSet }) =>
              result && !inIntersection(types, subtractedSet),
            inIntersection(types, vennArea.sets)
          );
          return isSelected;
        })
      )
      .map(({ interactor }) => interactor)
      .sort(({ label: labelA = '' }, { label: labelB = '' }) =>
        labelA.localeCompare(labelB)
      );
  }, [data, selections]);

  return (
    <div className={classes.root}>
      <div className={classes.toolbar}>
        <BrowseCollection
          collection={selectedInteractors}
          title="Browse gene set"
          renderButton={(props) => (
            <Badge
              color="secondary"
              badgeContent={selectedInteractors.length}
              invisible={!selectedInteractors.length}
            >
              <Button {...props}>
                View selected genes <PageViewIcon />
              </Button>
            </Badge>
          )}
        />
        <Button
          variant={'outlined'}
          onClick={venn.current.clearSelection}
          disabled={!selectedInteractors.length}
        >
          Clear <ClearIcon />
        </Button>
      </div>
      <div ref={d3Element} />
    </div>
  );
}

InteractorVennDiagram.propTypes = {
  classes: PropTypes.object.isRequired,
  data: PropTypes.arrayOf(
    PropTypes.shape({
      types: PropTypes.arrayOf(PropTypes.string),
      interactor: PropTypes.shape({
        id: PropTypes.string,
      }),
    })
  ),
};

const styles = (theme) => ({
  root: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    maxWidth: 600,
  },
  toolbar: {
    '& > *': {
      marginRight: theme.spacing.unit / 2,
    },
  },
});

export default withStyles(styles)(InteractorVennDiagram);
