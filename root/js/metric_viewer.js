
// CouchDB: URL and report database
var couchBaseUri = 'http://dev.wormbase.org:5984';
var couchReportDB = 'reports';

var overviewGraph = null;
var overviewData = {
  totalUrls: [],
  brokenUrls: [],
  imageMismatches: [],
  missingReferences: [],
  tracks: [],
  landmarks: []
};

function couchRequest(request, callback) {
  jQuery.ajax({
    type: 'GET',
    url: couchBaseUri + "/" + couchReportDB + "/" + request,
    processData: true,
    data: {},
    dataType: "json",
    success: function(data) {
      callback(data, null);
    },
    error: function(request, textStatus) {
      callback(null, textStatus);
    }
  });
}

function getReportListing(callback) {
  couchRequest("_all_docs", callback);
}

function getReportOverview(data, error) {
  if (error) {
     // TODO
     return;
  }

  if (data["type"] != "gbrowse" || !data["completed"])
    return;

  var totalUrls = 0;
  var brokenUrls = 0;
  var imageMismatches = 0;
  var missingReferences = 0;
  var tracks = 0;
  var landmarks = 0;
  for (var i = 0; i < data["configurations"].length; i++) {
    totalUrls += data[data["configurations"][i]]["total_urls"];
    brokenUrls += data[data["configurations"][i]]["broken_urls"];
    imageMismatches += data[data["configurations"][i]]["image_mismatches"];
    missingReferences += data[data["configurations"][i]]["missing_references"];
    tracks += data[data["configurations"][i]]["tracks"];
    landmarks += data[data["configurations"][i]]["example_landmarks"];
  }
  overviewData["totalUrls"].push([ data["started_since_epoch"] * 1000, totalUrls ]);
  overviewData["brokenUrls"].push([ data["started_since_epoch"] * 1000, brokenUrls ]);
  overviewData["imageMismatches"].push([ data["started_since_epoch"] * 1000, imageMismatches ]);
  overviewData["missingReferences"].push([ data["started_since_epoch"] * 1000, missingReferences ]);
  overviewData["tracks"].push([ data["started_since_epoch"] * 1000, tracks ]);
  overviewData["landmarks"].push([ data["started_since_epoch"] * 1000, landmarks ]);

  if (!overviewGraph) {
    overviewGraph = $.plot($("#overviewgraph"), [], {
      series: {
        lines: { show: true },
        points: { show: true }
      },
      xaxis: {
        mode: "time",
        timeformat: "%Y-%m-%dT%H:%M:%S"
      },
      yaxis: {
        min: 0
      }
    });
  }

  overviewGraph.setData([
    { label: "URLs in configuration files", data: overviewData["totalUrls"] },
    { label: "Tested URLs that were broken", data: overviewData["brokenUrls"] },
    { label: "Mismatching images (reference vs. actual)", data: overviewData["imageMismatches"] },
    { label: "URLs that lack a reference image", data: overviewData["missingReferences"] },
    { label: "Tracks", data: overviewData["tracks"] },
    { label: "Example landmarks", data: overviewData["landmarks"] }
  ]);
  overviewGraph.setupGrid();
  overviewGraph.draw();
}

function createOverviewGraph(data, error) {
  if (error) {
     // TODO
     return;
  }

  var records = data['rows'];
  for (var i = 0; i < records.length; i++) {
    couchRequest(records[i]["id"], getReportOverview);
  }
}

function renderOverview() {
  getReportListing(createOverviewGraph);
}

