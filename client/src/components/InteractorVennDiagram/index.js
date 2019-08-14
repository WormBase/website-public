import React, { useRef, useEffect } from 'react';
import PropTypes from 'prop-types';
import draw from './draw';
import { subsets, isSuperSet } from './utils';

export default function InteractorVennDiagram({ data = [] }) {
  const d3Element = useRef();

  useEffect(() => {
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

    draw(d3Element.current, vennSubsets, (key) => colorMap[key] || 'gray');
  }, [data, d3Element]);
  return <div ref={d3Element}>Place holder for venn diagram </div>;
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
