
var couchBaseUri = 'http://dev.wormbase.org:5984';
var couchReportDB = 'reports';

function getReportListing() {
  jQuery.ajax({
    type: 'GET',
    url: couchBaseUri + "/" + couchReportDB + "/_all_docs",
    processData: true,
    data: {},
    dataType: "json",
    success: function (data) {
      alert(data);
    }
  });
}

function renderOverview() {
  var graph = new Rickshaw.Graph({
    element: document.querySelector('#graph'),
    series: [
      {
        color: '#2C3E50',
        data: [ { x: 0, y: 23}, { x: 1, y: 15 }, { x: 2, y: 79 } ]
      }, {
        color: '#16A085',
        data: [ { x: 0, y: 30}, { x: 1, y: 20 }, { x: 2, y: 64 } ]
      }
    ]
  });

  new Rickshaw.Graph.HoverDetail({
      graph: graph,
      xFormatter: function(x) { return x + "seconds" },
      yFormatter: function(y) { return Math.floor(y) + " percent" }
  });

  graph.render();
}

