import React, { useRef, useEffect } from 'react';
import PropTypes from 'prop-types';
import { select, selectAll, event as d3event } from 'd3-selection';
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
    const div = select(d3Element.current);
    console.log(div.selectAll());

    div.datum(vennSubsets).call(chart);

    // Code below is lifted out of https://codepen.io/avnerz/pen/dJPWee?editors=1010, created by avnerz
    // to allow areas of set difference to be selected

    function getIntersectionAreasMapping() {
      let intersectionAreasMapping = {};
      let vennAreas = selectAll('.venn-area');
      vennAreas.each((areaData, areaIdx, areas) => {
        let area = areas[areaIdx];
        let areaSets = areaData.sets;
        let areaSelection = select(area);
        let areaD = areaSelection.select('path').attr('d');
        let areaSetsId = area.dataset.vennSets;
        let intersectedAreas = selectAll('.venn-area')
          .filter((cAreaData, cAreaIdx, cAreas) => {
            let cAreaSetsId = cAreas[cAreaIdx].dataset.vennSets;
            let cAreaSets = cAreaData.sets;
            let isContained = areaSets.every(
              (setId) => cAreaSets.indexOf(setId) > -1
            );
            return isContained && cAreaSetsId !== areaSetsId;
          })
          .nodes()
          .map((intersectedArea) => {
            let intersectedAreaSelection = select(intersectedArea);
            return {
              sets: intersectedAreaSelection.data()[0].sets,
              d: intersectedAreaSelection.select('path').attr('d'),
            };
          });

        intersectionAreasMapping[areaSetsId] = {
          vennArea: {
            sets: areaSets,
            d: areaD,
          },
          intersectedAreas: intersectedAreas,
        };
      });
      return intersectionAreasMapping;
    }

    function appendVennAreaParts(svg, intersectionAreasMapping) {
      for (let areaSetsId in intersectionAreasMapping) {
        let intersectionAreasItem = intersectionAreasMapping[areaSetsId];
        let vennArea = intersectionAreasItem.vennArea;
        let intersectedAreas = intersectionAreasItem.intersectedAreas;
        let partId = getPartId(vennArea, intersectedAreas);
        let d = [vennArea.d].concat(
          intersectedAreas.map((intersectedArea) => intersectedArea.d)
        );
        appendVennAreaPart(svg, d.join(''), partId);
      }
    }

    function appendLabels(svg, labels) {
      labels.nodes().forEach((label) => {
        svg.append(function() {
          return label;
        });
      });
    }

    function appendVennAreaPart(svg, d, partId) {
      svg
        .append('g')
        .attr('class', 'venn-area-part')
        .attr('venn-area-part-id', partId)
        .append('path')
        .attr('d', d)
        .attr('fill-rule', 'evenodd');
    }

    function appendPatterns(defs) {
      let colors = ['none', '#009fdf'];
      colors.forEach((color, idx) => {
        let diagonal = defs
          .append('pattern')
          .attr('id', 'diagonal' + idx)
          .attr('patternUnits', 'userSpaceOnUse')
          .attr('width', '10')
          .attr('height', '10');
        diagonal
          .append('rect')
          .attr('width', '10')
          .attr('height', '10')
          .attr('x', '0')
          .attr('y', '0')
          .attr('fill', color)
          .attr('fill-opacity', '0.15');
        diagonal
          .append('path')
          .attr('d', 'M-1,1 l2,-2 M0,10 l10,-10 M9,11 l2,-2')
          .attr('stroke', '#000000')
          .attr('opacity', '1')
          .attr('stroke-width', '1');
      });
    }

    function getPartId(vennArea, intersectedAreas) {
      let partId = '(' + vennArea.sets.join('∩') + ')';
      partId += intersectedAreas.length > 1 ? '\\(' : '';
      partId += intersectedAreas.length == 1 ? '\\' : '';
      partId += intersectedAreas
        .map((intersectedArea) => intersectedArea.sets)
        .map((set) => '(' + set.join('∩') + ')')
        .join('∪');
      partId += intersectedAreas.length > 1 ? ')' : '';
      return partId;
    }

    function bindVennAreaPartListeners() {
      div
        .selectAll('g')
        .on('mouseover', function(d, i) {
          let node = select(this);
          let nodePath = node.select('path');
          let nodeAlreadySelected = node.classed('selected');
          nodePath.attr(
            'style',
            nodeAlreadySelected
              ? 'fill: url(#diagonal1)'
              : 'fill: #009fdf; fill-opacity: 0.15'
          );
        })
        .on('mouseout', function(d, i) {
          let node = select(this);
          let nodePath = node.select('path');
          let nodeAlreadySelected = node.classed('selected');
          nodePath.attr(
            'style',
            nodeAlreadySelected ? 'fill: url(#diagonal0)' : 'fill: #ffffff'
          );
        })
        .on('click', function(d, i) {
          let node = select(this);
          let nodePath = node.select('path');
          let nodeAlreadySelected = node.classed('selected');
          let nodePathStyle = !nodeAlreadySelected
            ? 'fill: url(#diagonal1)'
            : 'fill: #ffffff';
          nodePath.attr('style', nodePathStyle);
          node.classed('selected', !nodeAlreadySelected);
        });
    }

    function removeOriginalVennAreas() {
      selectAll('g.venn-area').remove();
    }

    let svg = div.select('svg');
    let defs = svg.append('defs');
    let labels = div.selectAll('text').remove();
    let intersectionAreasMapping = getIntersectionAreasMapping();

    appendPatterns(defs);
    appendVennAreaParts(svg, intersectionAreasMapping);
    appendLabels(svg, labels);
    bindVennAreaPartListeners();
    removeOriginalVennAreas();

    // const tooltip = canvas.append('div').attr('class', 'venntooltip');

    // canvas
    //   .selectAll('path')
    //   .style('stroke-opacity', 0)
    //   .style('stroke', '#fff')
    //   .style('stroke-width', 3);

    // canvas
    //   .selectAll('g')
    //   .on('mouseover', function(d, i) {
    //     // sort all the areas relative to the current item
    //     sortAreas(canvas, d);

    //     // Display a tooltip with the current size
    //     tooltip
    //       .transition()
    //       .duration(400)
    //       .style('opacity', 0.9);
    //     tooltip.text(d.size + ' users');

    //     // highlight the current path
    //     const selection = select(this)
    //       .transition('tooltip')
    //       .duration(400);
    //     selection
    //       .select('path')
    //       .style('fill-opacity', d.sets.length == 1 ? 0.4 : 0.1)
    //       .style('stroke-opacity', 1);
    //   })

    //   .on('mousemove', function() {
    //     tooltip
    //       .style('left', d3event.pageX + 'px')
    //       .style('top', d3event.pageY - 28 + 'px');
    //   })

    //   .on('mouseout', function(d, i) {
    //     tooltip
    //       .transition()
    //       .duration(400)
    //       .style('opacity', 0);
    //     const selection = select(this)
    //       .transition('tooltip')
    //       .duration(400);
    //     selection
    //       .select('path')
    //       .style('fill-opacity', d.sets.length == 1 ? 0.25 : 0.0)
    //       .style('stroke-opacity', 0);
    //   });
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
