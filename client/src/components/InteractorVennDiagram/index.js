import React, { useRef, useEffect } from 'react';
import PropTypes from 'prop-types';
import { select, event as d3event } from 'd3-selection';
import { VennDiagram, sortAreas } from 'venn.js';

function combination([...list] = [], n) {
  if (list.length < n) {
    throw new Error(
      `Cannot pick ${n} items from a list of length ${list.length}`
    );
  } else if (n <= 0) {
    return [];
  } else if (n === 1) {
    return list.map((item) => [item]);
  } else if (n === list.length) {
    return [list];
  } else {
    const [item, ...rest] = list;
    return [
      ...combination(rest, n - 1).map((subCombo) => {
        return [item, ...subCombo];
      }),
      ...combination(rest, n),
    ];
  }
}

function subsets([...list] = [], minSize = 1, maxSize = list.length) {
  let results = [];
  for (let i = minSize; i <= maxSize; i++) {
    results = [...results, ...combination(list, i)];
  }
  return results;
}

// console.log(combination([1, 2, 3, 4], 4));
// console.log(combination([1, 2, 3, 4], 3));
// console.log(combination([1, 2, 3, 4], 2));
// console.log(combination([1, 2, 3, 4], 1));
// console.log(combination([1, 2, 3, 4], 0));
// console.log(subsets([1, 2, 3, 4]));
// console.log(subsets(['physical', 'genetic', 'regulatory']));

function isSuperSet(list1, list2) {
  // is list1 a super set of list2
  const set1 = new Set(list1);
  return list2.every((item) => set1.has(item));
}

// console.log(isSuperSet([1, 2, 3], [2, 3]));

export default function InteractorVennDiagram({ data = [] }) {
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

  const d3Element = useRef();

  useEffect(() => {
    const chart = VennDiagram();
    const canvas = select(d3Element.current);
    console.log(canvas.selectAll());

    canvas.datum(vennSubsets).call(chart);

    const tooltip = canvas.append('div').attr('class', 'venntooltip');

    canvas
      .selectAll('path')
      .style('stroke-opacity', 0)
      .style('stroke', '#fff')
      .style('stroke-width', 3);

    canvas
      .selectAll('g')
      .on('mouseover', function(d, i) {
        // sort all the areas relative to the current item
        sortAreas(canvas, d);

        // Display a tooltip with the current size
        tooltip
          .transition()
          .duration(400)
          .style('opacity', 0.9);
        tooltip.text(d.size + ' users');

        // highlight the current path
        const selection = select(this)
          .transition('tooltip')
          .duration(400);
        selection
          .select('path')
          .style('fill-opacity', d.sets.length == 1 ? 0.4 : 0.1)
          .style('stroke-opacity', 1);
      })

      .on('mousemove', function() {
        tooltip
          .style('left', d3event.pageX + 'px')
          .style('top', d3event.pageY - 28 + 'px');
      })

      .on('mouseout', function(d, i) {
        tooltip
          .transition()
          .duration(400)
          .style('opacity', 0);
        const selection = select(this)
          .transition('tooltip')
          .duration(400);
        selection
          .select('path')
          .style('fill-opacity', d.sets.length == 1 ? 0.25 : 0.0)
          .style('stroke-opacity', 0);
      });
  }, [data, VennDiagram, select]);
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
