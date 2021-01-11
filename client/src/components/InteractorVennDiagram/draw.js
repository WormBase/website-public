import { select, selectAll, event as d3event } from 'd3-selection';
import { VennDiagram } from 'venn.js';

export default function draw(
  node,
  sets,
  coloursFunc,
  { onAreaSelectionUpdate } = {}
) {
  const chart = VennDiagram();
  chart.colours(coloursFunc);
  const div = select(node);
  div.datum(sets).call(chart);

  let isSupportedBrowser = true;
  selectAll('.venn-area').each((areaData, areaIdx, areas) => {
    const area = areas[areaIdx];
    if (!area.dataset) {
      isSupportedBrowser = false;
    }
  });
  if (!isSupportedBrowser) {
    return {};
  }

  const getAreaD = (function() {
    const dMap = {};
    selectAll('.venn-area').each((areaData, areaIdx, areas) => {
      const area = areas[areaIdx];
      let areaSetsId = area.dataset.vennSets;
      dMap[areaSetsId] = {
        d: select(area)
          .select('path')
          .attr('d'),
        size: areaData.size,
      };
    });

    // hack to fix incorrect d for .venn-intersection that should superimpose exactly a .venn-circle
    selectAll('.venn-intersection').each((areaData, areaIdx, areas) => {
      const area = areas[areaIdx];
      let areaSetsId = area.dataset.vennSets;
      console.log(areaData, area.dataset);
      areaData.sets.forEach((setId) => {
        if (areaData.size === dMap[setId].size) {
          dMap[areaSetsId] = dMap[setId];
        }
      });
    });

    return (areaSetsId) => {
      return dMap[areaSetsId] && dMap[areaSetsId].d;
    };
  })();

  // Code below is modified from https://codepen.io/avnerz/pen/dJPWee?editors=1010, created by avnerz
  // to allow areas of set difference to be selected

  function getIntersectionAreasMapping() {
    let intersectionAreasMapping = {};
    let vennAreas = selectAll('.venn-area');
    vennAreas.each((areaData, areaIdx, areas) => {
      let area = areas[areaIdx];
      let areaSets = areaData.sets;
      let areaSetsId = area.dataset.vennSets;
      let areaD = getAreaD(areaSetsId);

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
          const intersectedAreaSetsId = intersectedArea.dataset.vennSets;
          return {
            sets: intersectedAreaSelection.data()[0].sets,
            d: getAreaD(intersectedAreaSetsId),
            size: intersectedAreaSelection.data()[0].size,
          };
        });

      intersectionAreasMapping[areaSetsId] = {
        vennArea: {
          sets: areaSets,
          d: areaD,
          size: areaData.size,
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
      let partSize = getPartSize(vennArea, intersectedAreas);
      let partDescriptor = JSON.stringify({
        vennArea,
        intersectedAreas,
        partSize,
      });
      let d = [vennArea.d].concat(
        intersectedAreas.map((intersectedArea) => intersectedArea.d)
      );
      appendVennAreaPart(svg, d.join(''), { partId, partDescriptor, partSize });
    }
  }

  function appendLabels(svg, labels) {
    labels.nodes().forEach((label) => {
      select(label).attr('font-weight', 'bold');
      svg.append(function() {
        return label;
      });
    });
  }

  function appendVennAreaPart(
    svg,
    d,
    { partId, partDescriptor, partSize } = {}
  ) {
    svg
      .append('g')
      .attr('class', 'venn-area-part')
      .attr('venn-area-part-id', partId)
      .attr('venn-area-part-descriptor', partDescriptor)
      .attr('venn-area-part-size', partSize)
      .append('path')
      .attr('d', d)
      .attr('fill-rule', 'evenodd')
      .attr('fill-opacity', '0');
  }

  function appendPatterns(defs) {
    let colors = ['none', '#000000'];
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
        .attr('fill-opacity', '0.15')
        .attr('fill', color);
      diagonal
        .append('path')
        .attr('d', 'M-1,1 l2,-2 M0,10 l10,-10 M9,11 l2,-2')
        .attr('stroke', '#000000')
        .attr('opacity', '0.5')
        .attr('stroke-width', '1');
    });
  }

  function getPartId(vennArea, intersectedAreas) {
    let partId = '(' + vennArea.sets.join('∩') + ')';
    partId += intersectedAreas.length > 1 ? '\\(' : '';
    partId += intersectedAreas.length === 1 ? '\\' : '';
    partId += intersectedAreas
      .map((intersectedArea) => intersectedArea.sets)
      .map((set) => '(' + set.join('∩') + ')')
      .join('∪');
    partId += intersectedAreas.length > 1 ? ')' : '';
    return partId;
  }

  function getPartSize(vennArea, intersectedAreas) {
    const intersectedSize = intersectedAreas.reduce(
      (sum, intersectedArea) =>
        sum +
        (intersectedAreas.length === 3 && intersectedArea.sets.length === 3
          ? -1
          : 1) *
          intersectedArea.size, // this hack only works with venn digram with <= 3 circles
      0
    );
    return vennArea.size - intersectedSize;
  }

  function colorVennAreaPart(node, { isHover }) {
    let nodePath = node.select('path');
    let isNodeAlreadySelected = node.classed('selected');
    let style;
    if (isHover && isNodeAlreadySelected) {
      style = 'fill: url(#diagonal1); fill-opacity: 1';
    } else if (isHover && !isNodeAlreadySelected) {
      style = 'fill: #000000; fill-opacity: 0.15';
    } else if (!isHover && isNodeAlreadySelected) {
      style = 'fill: url(#diagonal0); fill-opacity: 1';
    } else {
      style = 'fill-opacity: 0';
    }
    nodePath.attr('style', style);
  }

  function handleAreaSelectionUpdate() {
    onAreaSelectionUpdate &&
      onAreaSelectionUpdate(
        div
          .selectAll('g.venn-area-part.selected')
          .nodes()
          .map((area) => ({
            id: select(area).attr('venn-area-part-id'),
            ...JSON.parse(select(area).attr('venn-area-part-descriptor')),
          }))
      );
  }

  function bindVennAreaPartListeners() {
    var tooltip = select('body')
      .append('div')
      .style('position', 'absolute')
      .style('text-align', 'center')
      //      .style('width', '128px')
      .style('height', '20px')
      .style('background', '#333')
      .style('color', '#ddd')
      .style('padding', '3px 5px')
      .style('border', '0px')
      .style('border-radius', '8px')
      .style('opacity', 0)
      .attr('class', 'venntooltip');

    div
      .selectAll('g')
      .on('mouseover', function(d, i) {
        colorVennAreaPart(select(this), { isHover: true });
        tooltip
          .transition()
          .duration(400)
          .style('opacity', 0.9);
        console.log(select(this).attr('venn-area-part-size'));
        tooltip.text(select(this).attr('venn-area-part-size') + ' genes');
      })
      .on('mousemove', function() {
        tooltip
          .style('left', d3event.pageX + 'px')
          .style('top', d3event.pageY - 28 + 'px');
      })

      .on('mouseout', function(d, i) {
        colorVennAreaPart(select(this), { isHover: false });
        tooltip
          .transition()
          .duration(400)
          .style('opacity', 0);
      })
      .on('click', function(d, i) {
        const node = select(this);
        node.classed('selected', !node.classed('selected'));
        colorVennAreaPart(node, { isHover: true });
        handleAreaSelectionUpdate();
      });
  }

  // function removeOriginalVennAreas() {
  //   selectAll('g.venn-area').remove();
  // }

  function clearSelection() {
    div
      .selectAll('g.venn-area-part')
      .nodes()
      .forEach((area) => {
        select(area).classed('selected', false);
        colorVennAreaPart(select(area), { isHover: false });
      });
    handleAreaSelectionUpdate();
  }

  let svg = div.select('svg');
  let defs = svg.append('defs');
  let labels = div.selectAll('text').remove();
  let intersectionAreasMapping = getIntersectionAreasMapping();
  console.log(intersectionAreasMapping);
  appendPatterns(defs);
  appendLabels(svg, labels);
  appendVennAreaParts(svg, intersectionAreasMapping);
  bindVennAreaPartListeners();
  // removeOriginalVennAreas();

  return {
    clearSelection,
  };
}
