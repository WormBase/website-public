import cytoscape from 'cytoscape';
import dagre from 'cytoscape-dagre';
import cyqtip from 'cytoscape-qtip';

var $jq = window.$jq;
cytoscape.use(cyqtip); // register extension
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

export default function setupCyOntologyGraph(elements, datatype) {
  var containerElement = document.getElementById('cy' + datatype + 'Graph');
  var loadingElement = document.getElementById(
    'cy' + datatype + 'GraphLoading'
  );
  var controlsElement = document.getElementById('controlsdiv' + datatype);
  var infoElement = document.getElementById('info' + datatype);
  var radioWeightedElement = document.getElementById(
    'radioWeighted' + datatype
  );
  var radioUnweightedElement = document.getElementById(
    'radioUnweighted' + datatype
  );
  var weightstateElement = document.getElementById('weightstate' + datatype);
  var pngExportElement = document.getElementById('pngExport' + datatype);
  var viewPngButtonElement = document.getElementById(
    'viewPngButton' + datatype
  );
  var viewEditButtonElement = document.getElementById(
    'viewEditButton' + datatype
  );
  var maxDepthElement = document.getElementById('maxDepth' + datatype);
  var focusTermIdElement = document.getElementById('focusTermId' + datatype);
  var urlBaseElement = document.getElementById('urlBase' + datatype);
  var updatingElements = document.getElementById('updatingElements' + datatype);

  console.log(datatype + ' ' + elements.nodes[0].data.id);

  var cyOntologyGraph = cytoscape({
    container: containerElement,
    layout: { name: 'dagre', padding: 10, nodeSep: 5 },
    style: cytoscape
      .stylesheet()
      .selector('node')
      .css({
        content: 'data(name)',
        'background-color': 'data(backgroundColor)',
        shape: 'data(nodeShape)',
        'border-color': 'data(nodeColor)',
        'border-style': 'data(borderStyle)',
        'border-width': 'data(borderWidth)',
        width: 'data(diameter)',
        height: 'data(diameter)',
        'text-valign': 'center',
        'text-wrap': 'wrap',
        //               'min-zoomed-font-size': 8,
        'border-opacity': 0.3,
        'background-opacity': 0.3,
        'font-size': 'data(fontSize)',
      })
      .selector('edge')
      .css({
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
      }),
    elements: elements,
    wheelSensitivity: 0.2,
  });

  cyOntologyGraph.ready(function() {
    cyOntologyGraph.elements().unselectify();
    $jq(loadingElement).hide();

    var focusTermId = elements.meta.focusTermId;
    console.log('got ' + focusTermId);
    focusTermIdElement.value = focusTermId;
    var urlBase = elements.meta.urlBase;
    console.log('got ' + urlBase);
    urlBaseElement.value = urlBase;

    //            var maxOption = 7;
    var maxOption = elements.meta.fullDepth;
    maxDepthElement.options.length = 0;
    for (var i = 1; i <= maxOption; i++) {
      var label = i;
      //             if ((i == 0) || (i == maxOption)) { label = 'max'; }
      maxDepthElement.options[i - 1] = new Option(label, i, true, false);
    }
    maxDepthElement.selectedIndex = maxOption - 1;

    cyOntologyGraph.on('mouseover', 'edge', function(e) {
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
      edge.qtip(
        {
          position: {
            my: 'top center',
            at: 'bottom center',
          },
          style: {
            classes: 'qtip-bootstrap',
            tip: {
              width: 16,
              height: 8,
            },
          },
          content: qtipContent,
          show: {
            e: e.type,
            ready: true,
          },
          hide: {
            e: 'mouseout unfocus',
          },
        },
        e
      );
    });

    cyOntologyGraph.on('tap', 'node', function(e) {
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

      //             var qtipContent = annotCounts + '<br/><a target="_blank" href="http://www.wormbase.org/species/all/phenotype/WBPhenotype:' + nodeId + '#03--10">' + nodeName + '</a>';
      node.qtip(
        {
          position: {
            my: 'top center',
            at: 'bottom center',
          },
          style: {
            classes: 'qtip-bootstrap',
            tip: {
              width: 16,
              height: 8,
            },
          },
          content: qtipContent,
          show: {
            e: e.type,
            ready: true,
          },
          hide: {
            e: 'mouseout unfocus',
          },
        },
        e
      );
    });

    cyOntologyGraph.on('tap', function(e) {
      if (e.target === cyOntologyGraph) {
        cyOntologyGraph.elements().removeClass('faded');
      }
    });

    cyOntologyGraph.on('mouseover', 'node', function(event) {
      var node = event.target;
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
      //               var qtipContent = annotCounts + '<br/><a target="_blank" href="http://www.wormbase.org/species/all/phenotype/WBPhenotype:' + nodeId + '#03--10">' + nodeName + '</a>';
      $jq(infoElement).html(qtipContent);
    });
  });

  $jq(radioWeightedElement).on('click', function() {
    var nodes = cyOntologyGraph.nodes();
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      var nodeId = node.data('id');
      var diameterWeighted = node.data('diameter_weighted');
      cyOntologyGraph.$('#' + nodeId).data('diameter', diameterWeighted);
      var fontSizeWeighted = node.data('fontSizeWeighted');
      cyOntologyGraph.$('#' + nodeId).data('fontSize', fontSizeWeighted);
      var borderWidthWeighted = node.data('borderWidthWeighted');
      cyOntologyGraph.$('#' + nodeId).data('borderWidth', borderWidthWeighted);
    }
    cyOntologyGraph.layout({ name: 'dagre', padding: 10, nodeSep: 5 }).run();
  });
  $jq(radioUnweightedElement).on('click', function() {
    var nodes = cyOntologyGraph.nodes();
    console.log('clicked ' + radioUnweightedElement);
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      var nodeId = node.data('id');
      var diameterUnweighted = node.data('diameter_unweighted');
      var diameterWeighted = node.data('diameter_weighted');
      cyOntologyGraph.$('#' + nodeId).data('diameter', diameterUnweighted);
      var fontSizeUnweighted = node.data('fontSizeUnweighted');
      var fontSizeWeighted = node.data('fontSizeWeighted');
      cyOntologyGraph.$('#' + nodeId).data('fontSize', fontSizeUnweighted);
      var borderWidthUnweighted = node.data('borderWidthUnweighted');
      var borderWidthWeighted = node.data('borderWidthWeighted');
      cyOntologyGraph
        .$('#' + nodeId)
        .data('borderWidth', borderWidthUnweighted);
    }
    cyOntologyGraph.layout({ name: 'dagre', padding: 10, nodeSep: 5 }).run();
  });
  $jq(viewPngButtonElement).on('click', function() {
    var png64 = cyOntologyGraph.png({
      full: true,
      maxWidth: 8000,
      maxHeight: 8000,
      bg: 'white',
    });
    $jq(pngExportElement).attr('src', png64);
    $jq(pngExportElement).show();
    $jq(containerElement).hide();
    $jq(weightstateElement).hide();
    $jq(viewPngButtonElement).hide();
    $jq(viewEditButtonElement).show();
    $jq(infoElement).text(
      'drag image to desktop, or right-click and save image as'
    );
  });
  $jq(viewEditButtonElement).on('click', function() {
    $jq(pngExportElement).hide();
    $jq(containerElement).show();
    $jq(weightstateElement).show();
    $jq(viewPngButtonElement).show();
    $jq(viewEditButtonElement).hide();
  });

  var updatingElementsArray = updatingElements.value.split('|');
  updatingElementsArray.forEach(function(element) {
    $jq('#' + element).on('click', { name: element }, updateElements);
  });

  $jq(maxDepthElement).on('change', { name: 'maxDepthChange' }, updateElements);
  function updateElements(event) {
    console.log('updateElements from ' + event.data.name);
    $jq(loadingElement).show();
    $jq(controlsElement).hide();

    var radioEtgo = $jq('input[name=radio_etgo]:checked').val();
    var radioEtp = $jq('input[name=radio_etp]:checked').val();
    var radioEtd = $jq('input[name=radio_etd]:checked').val();
    var radioEta = $jq('input[name=radio_eta]:checked').val();
    //         console.log('radioEtp ' + radioEtp + ' end');
    //         var rootsPossible = ['root_bp', 'root_cc', 'root_mf'];
    //         var rootsChosen = [];

    // //         var showControlsFlagValue = '0'; if (\$('#showControlsFlag').is(':checked')) { showControlsFlagValue = 1; }
    // //         var fakeRootFlagValue = '0'; if (\$('#fakeRootFlag').is(':checked')) { fakeRootFlagValue = 1; }
    // //         var filterForLcaFlagValue = '0'; if (\$('#filterForLcaFlag').is(':checked')) { filterForLcaFlagValue = 1; }
    // //         var filterLongestFlagValue = '0'; if (\$('#filterLongestFlag').is(':checked')) { filterLongestFlagValue = 1; }
    // //         var maxNodes = '0'; if (\$('#maxNodes').val()) { maxNodes = \$('#maxNodes').val(); }

    //         rootsPossible.forEach(function(rootTerm) {
    //           if (document.getElementById(rootTerm).checked) { rootsChosen.push(document.getElementById(rootTerm).value); } });
    //         var rootsChosenGroup = rootsChosen.join(',');

    var maxDepth = 0;
    if (event.data.name === 'maxDepthChange') {
      if (maxDepthElement.value) {
        maxDepth = maxDepthElement.value;
      }
    }

    var urlBase = '';
    if (urlBaseElement.value) {
      urlBase = urlBaseElement.value;
    }

    //            var url = 'https://wobr2.caltech.edu/~raymond/cgi-bin/soba_biggo.cgi?action=annotSummaryJsonp&focusTermId=' + focusTermIdElement.value + '&datatype=lifestage&radio_etl=&showControlsFlag=0&fakeRootFlag=0&filterForLcaFlag=1&filterLongestFlag=1&maxNodes=0&maxDepth=3';
    //            var url = 'https://wobr2.caltech.edu/~raymond/cgi-bin/soba_biggo.cgi?action=annotSummaryJsonp&focusTermId=' + focusTermIdElement.value + '&datatype=' + datatype + '&radio_etl=&showControlsFlag=0&fakeRootFlag=0&filterForLcaFlag=1&filterLongestFlag=1&maxNodes=0&maxDepth=' + maxDepth;
    var url =
      urlBase +
      '&showControlsFlag=0&fakeRootFlag=0&filterForLcaFlag=1&filterLongestFlag=1&maxNodes=0&maxDepth=' +
      maxDepth;

    //         var url = 'soba_biggo.cgi?action=annotSummaryJson&focusTermId=$focusTermId&datatype=$datatype';
    if (datatype === 'Go' || datatype === 'Biggo') {
      url += '&radio_etgo=' + radioEtgo;
    } else if (datatype === 'Phenotype') {
      url += '&radio_etp=' + radioEtp;
    } else if (datatype === 'Disease') {
      url += '&radio_etd=' + radioEtd;
    } else if (datatype === 'Anatomy') {
      url += '&radio_eta=' + radioEta;
    }
    if (datatype === 'Go' || datatype === 'Biggo') {
      var rootsPossible = document.getElementById('rootsPossible' + datatype);
      var rootsChosen = [];
      var rootsPossibleArray = rootsPossible.value.split('|');
      rootsPossibleArray.forEach(function(rootTerm) {
        if (document.getElementById(rootTerm).checked) {
          rootsChosen.push(document.getElementById(rootTerm).value);
        }
      });
      var rootsChosenGroup = rootsChosen.join(',');
      url += '&rootsChosen=' + rootsChosenGroup;
    }

    //         url += '&rootsChosen=' + rootsChosenGroup + '&showControlsFlag=' + showControlsFlagValue + '&fakeRootFlag=' + fakeRootFlagValue + '&filterForLcaFlag=' + filterForLcaFlagValue + '&filterLongestFlag=' + filterLongestFlagValue + '&maxNodes=' + maxNodes + '&maxDepth=' + maxDepth;
    console.log('url ' + url);
    var graphPNew = $jq.ajax({
      url: url,
      type: 'GET',
      jsonpCallback: 'jsonCallback' + datatype,
      dataType: 'jsonp',
    });
    Promise.all([graphPNew]).then(newCy);
    function newCy(then) {
      var elementsNew = then[0].elements;
      $jq(loadingElement).hide();
      $jq(controlsElement).show();
      cyOntologyGraph.json({ elements: elementsNew });
      cyOntologyGraph
        .elements()
        .layout({ name: 'dagre', padding: 10, nodeSep: 5 });

      var maxOption = elementsNew.meta.fullDepth;
      var userSelectedValue =
        maxDepthElement.options[maxDepthElement.selectedIndex].value;
      maxDepthElement.options.length = 0;
      for (var i = 1; i <= maxOption; i++) {
        maxDepthElement.options[i - 1] = new Option(i, i, true, false);
      }
      maxDepthElement.selectedIndex = maxOption - 1;
      if (event.data.name === 'maxDepthChange') {
        maxDepthElement.value = userSelectedValue;
      }
      //           if (userSelectedValue <= maxDepthElement.value) { maxDepthElement.value = userSelectedValue; }
    }
  } // function updateElements()
} // function setupCyOntologyGraph(elements, datatype)
