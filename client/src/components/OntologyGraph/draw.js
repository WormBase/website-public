import cytoscape from 'cytoscape';
import dagre from 'cytoscape-dagre';
import cyqtip from 'cytoscape-qtip';
import popper from 'cytoscape-popper';
import tippy from 'tippy.js';
import 'tippy.js/themes/light-border.css';

var $jq = window.$jq;
cytoscape.use(popper); // register extension
cytoscape.use(dagre); // register extension

function linkFromEdge(nodeObjId, datatype) {
  // generate url from datatype + edge's target node's objId
  var linkout = '';
  if (datatype === 'Anatomy') {
    linkout =
      'https://wormbase.org/species/all/anatomy_term/' + nodeObjId + '#4--10';
  } else if (datatype === 'Disease') {
    linkout = 'https://wormbase.org/resources/disease/' + nodeObjId + '#2--10';
  } else if (datatype === 'Go') {
    linkout =
      'https://wormbase.org/species/all/go_term/' + nodeObjId + '#2--10';
  } else if (datatype === 'Lifestage') {
    linkout =
      'https://wormbase.org/species/all/life_stage/' + nodeObjId + '#2--10';
  } else if (datatype === 'Phenotype') {
    linkout =
      'https://wormbase.org/species/all/phenotype/' + nodeObjId + '#3--10';
  } else if (datatype === 'Biggo') {
    linkout = '';
  }
  return linkout;
}

function linkFromNode(nodeId, datatype) {
  // generate url from datatype + nodeId
  var linkout = 'http://amigo.geneontology.org/amigo/term/' + nodeId;
  if (datatype === 'Anatomy') {
    linkout = 'https://wormbase.org/species/all/anatomy_term/' + nodeId;
  } else if (datatype === 'Disease') {
    linkout = 'https://wormbase.org/resources/disease/' + nodeId;
  } else if (datatype === 'Go') {
    linkout = 'https://wormbase.org/species/all/go_term/' + nodeId;
  } else if (datatype === 'Lifestage') {
    linkout = 'https://wormbase.org/species/all/life_stage/' + nodeId;
  } else if (datatype === 'Phenotype') {
    linkout = 'https://wormbase.org/species/all/phenotype/' + nodeId;
  } else if (datatype === 'Biggo') {
    linkout = 'http://amigo.geneontology.org/amigo/term/' + nodeId;
  }
  return linkout;
}

export const defaultLegendData = [
  {
    data: { id: 'legend', name: 'Legend' },
  },

  {
    data: {
      id: 'a',
      parent: 'legend',
      name: 'Term with inferred annotation',
      annotationDirectness: 'inferred',
    },
  },
  {
    data: {
      id: 'b',
      parent: 'legend',
      name: 'Term with direct annotation',
      annotationDirectness: 'direct',
    },
  },
  {
    data: {
      id: 'ab',
      parent: 'legend',
      name: 'direction of inference',
      source: 'a',
      target: 'b',
    },
    classes: 'autorotate',
  },
];

export function setupCytoscape(
  containerElement,
  datatype,
  data = [],
  { legendData = defaultLegendData, onReady, isWeighted } = {}
) {
  const layout = {
    name: 'dagre',
    padding: 10,
    nodeSep: 50,
    nodeDimensionsIncludeLabels: false,
  };
  console.log(legendData);
  console.log(data);
  var cyOntologyGraph = cytoscape({
    container: containerElement,
    layout: layout,
    userZoomingEnabled: false,
    autoungrabify: true,
    selectionType: 'single',
    style: cytoscape
      .stylesheet()
      .selector('node')
      .css({
        content: 'data(name)',
        'background-color': (node) => {
          return node.data('backgroundColor') &&
            node.data('backgroundColor') !== 'white'
            ? '#acd'
            : '#fff';
        }, // 'data(backgroundColor)',
        'background-opacity': 0.5,
        shape: 'data(nodeShape)',
        // 'border-color': 'data(nodeColor)',
        // 'border-style': 'data(borderStyle)',
        // 'border-width': 'data(borderWidth)',
        'border-style': 'solid',
        'border-width': (node) => {
          return node.data(
            isWeighted ? 'borderWidthWeighted' : 'borderWidthUnweighted'
          );
        },
        width: (node) => {
          return node.data(
            isWeighted ? 'diameter_weighted' : 'diameter_unweighted'
          );
        },
        height: (node) => {
          return node.data(
            isWeighted ? 'diameter_weighted' : 'diameter_unweighted'
          );
        },
        'text-valign': 'center',
        'text-wrap': 'wrap',
        //               'min-zoomed-font-size': 8,
        'border-opacity': 0.3,
        'font-size': (node) => {
          return node.data(
            isWeighted ? 'fontSizeWeighted' : 'fontSizeUnweighted'
          );
        },
      })
      .selector('node[annotationDirectness = "direct"]')
      .css({
        'border-style': 'solid',
        'border-color': 'red',
      })
      .selector('node[annotationDirectness = "inferred"]')
      .css({
        'border-style': 'dashed',
        'border-color': 'blue',
      })
      .selector('edge')
      .css({
        'curve-style': 'straight',
        'target-arrow-shape': 'none',
        'source-arrow-shape': 'triangle',
        width: 2,
        'line-color': '#ddd',
        'target-arrow-color': '#ddd',
        'source-arrow-color': '#ddd',
      })
      .selector('.highlighted')
      .css({
        'background-color': '#61bffc',
        'line-color': '#61bffc',
        'target-arrow-color': '#61bffc',
        'transition-property':
          'background-color, line-color, target-arrow-color',
        'transition-duration': '0.5s',
      })
      .selector('.faded')
      .css({
        opacity: 0.25,
        'text-opacity': 0,
      })
      .selector(':selected')
      .css({
        //    'line-color': 'red',
      })
      .selector('#legend')
      .css({
        'text-valign': 'top',
        'text-halign': 'center',
        'font-weight': '500',
        'background-color': '#fff',
        'border-width': 2,
      })
      .selector('node[parent="legend"]')
      .css({
        'font-size': '0.9em',
        'text-halign': 'left',
        'text-max-width': '8em',
        'border-width': 2,
      })
      .selector('edge[parent="legend"]')
      .css({
        label: 'data(name)',
        'font-size': '0.9em',
        'text-halign': 'left',
        'text-valign': 'top',
        //        'text-rotation': 'autorotate',
        'text-margin-x': '-3em',
      }),
    elements: data.length ? [...defaultLegendData, ...legendData, ...data] : [],
    wheelSensitivity: 0.2,
  });

  cyOntologyGraph.ready(function() {
    // cyOntologyGraph
    //   .nodes('[parent="legend"]')
    //   .layout({ name: 'null', fit: false })
    //   .run();
    // cyOntologyGraph
    //   .nodes('[parent="legend"]')
    //   .layout({
    //     name: 'grid',
    //     cols: 1,
    //     fit: false,
    //     avoidOverlapPadding: 50,
    //     // animate: false,
    //     // padding: 10,
    //     // nodeSep: 50,
    //   })
    //   .run();

    // const nonLegendElements = cyOntologyGraph.$(
    //   '[parent != "legend"][id != "legend"]'
    // );
    // console.log(nonLegendElements.jsons());
    let lastTippy;

    const makeTippy = function(ele, text) {
      const elePopperRef = ele.popperRef();

      lastTippy && lastTippy.destroy();
      lastTippy = tippy(ele.popperRef(), {
        content: function() {
          var div = document.createElement('div');

          div.innerHTML = text;

          return div;
        },
        trigger: 'manual',
        interactive: true,
        theme: 'light-border',
        arrow: true,
        placement: 'bottom',
        hideOnClick: false,
        multiple: true,
        sticky: false,
      });

      lastTippy.show();
    };

    cyOntologyGraph.on('unselect', () => {
      lastTippy && lastTippy.destroy();
    });

    cyOntologyGraph.on('select', 'edge[parent != "legend"]', function(e) {
      var edge = e.target;
      var nodeId = edge.data('target');
      var nodeObj = cyOntologyGraph.getElementById(nodeId);
      var nodeObjId = nodeObj.data('objId');
      var nodeName = nodeObj.data('name');
      var linkout = linkFromEdge(nodeObjId, datatype);
      var qtipContent = 'No information';
      if (linkout) {
        qtipContent =
          'Explore <a target="_blank" href="' +
          linkout +
          '">' +
          nodeName +
          '</a> graph';
      }
      makeTippy(edge, qtipContent);
    });

    cyOntologyGraph.on(
      'select',
      'node[parent != "legend"][id != "legend"]',
      function(e) {
        var node = e.target;
        var nodeId = node.data('id');
        var neighborhood = node.neighborhood().add(node);
        cyOntologyGraph.elements().addClass('faded');
        neighborhood.removeClass('faded');

        var node = e.target;
        var nodeId = node.data('id');
        var objId = node.data('objId');
        var nodeName = node.data('name');
        var annotCounts = node.data('annotCounts');
        var linkout = linkFromNode(objId, datatype);
        var qtipContent =
          'Annotation Count:<br/>' +
          annotCounts +
          '<br/><a target="_blank" href="' +
          linkout +
          '">' +
          objId +
          ' - ' +
          nodeName +
          '</a>';
        makeTippy(node, qtipContent);
      }
    );

    cyOntologyGraph.on('tap', function(e) {
      if (e.target === cyOntologyGraph) {
        cyOntologyGraph.elements().removeClass('faded');
      }
    });

    onReady && onReady();
  });

  function handleExport(options = {}) {
    return cyOntologyGraph.png({
      full: true,
      bg: 'white',
      output: 'blob-promise',
      ...options,
    });
    // console.log(imgSrc);
    // return imgSrc;
  }

  function handleLock(isLocked) {
    cyOntologyGraph.userZoomingEnabled(!isLocked);
  }

  return { handleExport, handleLock };
}
