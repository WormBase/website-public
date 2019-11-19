import React, { useRef, useEffect, useState, useMemo } from 'react';
import PropTypes from 'prop-types';
import Badge from '@material-ui/core/Badge';
import Typography from '@material-ui/core/Typography';
import BrowseCollection from '../BrowseCollection';
import Button from '../Button';
import draw from './draw';
import { subsets, isSuperSet } from './utils';

export default function InteractorVennDiagram({ data = [] }) {
  const d3Element = useRef();
  const venn = useRef({});
  const [selections, setSelections] = useState([]);

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
          physical: '#33a02c',
          genetic: '#6a3d9a',
          regulatory: '#ff7f00',
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
      .map(({ interactor }) => interactor);
  }, [data, selections]);

  return (
    <div>
      <BrowseCollection
        collection={selectedInteractors}
        renderButton={(props) => (
          <Badge
            color="secondary"
            badgeContent={selectedInteractors.length}
            invisible={!selectedInteractors.length}
          >
            <Button {...props}>Browse selected</Button>
          </Badge>
        )}
      />
      {selectedInteractors.length ? (
        <Button variant={'outlined'} onClick={venn.current.clearSelection}>
          Clear selection
        </Button>
      ) : null}
      <div ref={d3Element}>Place holder for venn diagram </div>
    </div>
  );
}

InteractorVennDiagram.propTypes = {
  data: PropTypes.arrayOf(
    PropTypes.shape({
      types: PropTypes.arrayOf(PropTypes.string),
      interactor: PropTypes.shape({
        id: PropTypes.string,
      }),
    })
  ),
};
