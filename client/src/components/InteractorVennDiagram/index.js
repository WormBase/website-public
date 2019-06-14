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

    const vennSubsets = subsets(typeSet)
      .map((s) => {
        return {
          sets: s,
          size: data.filter(({ types: interactorTypes }) =>
            isSuperSet(interactorTypes, s)
          ).length,
        };
      })
      .filter(({ size }) => size > 0);

    draw(d3Element.current, vennSubsets);
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
