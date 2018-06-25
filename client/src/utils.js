const importLazy = (promise, {globalName}={}) => (
  promise.then((result) => {
    if (result) {
      if (globalName) {
        window[globalName] = result;
      }
      return result;
    } else if (window && globalName) {
      return window[globalName];
    }
  })
);

class LegacyPlugin {
  static getPlugin(pluginKey, callback) {
    const pluginPromise = (LegacyPlugin.lookup[pluginKey])();
    if (pluginPromise) {
      pluginPromise.then(callback);
    }
  }
}

LegacyPlugin.lookup = {
  highlight: () => importLazy(import("../../root/js/jquery/plugins/jquery.highlight-1.1.js")),
  dataTables: () => importLazy(Promise.all([
    import("../../root/js/jquery/plugins/dataTables/media/js/jquery.dataTables.min.js"),
    import("../../root/js/jquery/plugins/dataTables/media/css/demo_table.css")
  ])),
  colorbox: () => importLazy(Promise.all([
    import("../../root/js/jquery/plugins/colorbox/colorbox/jquery.colorbox-min.js"),
    import("../../root/js/jquery/plugins/colorbox/colorbox/colorbox.css")
  ])),
  generateFile: () => importLazy(import("../../root/js/jquery/plugins/generateFile.js")),
  pfam: () => importLazy(import("../../root/js/pfam/domain_graphics.min.js")),
  markitup: () => importLazy(Promise.all([
    import("../../root/js/jquery/plugins/markitup/jquery.markitup.js"),
    import("../../root/js/jquery/plugins/markitup/skins/markitup/style.css")
  ])),
  "markitup-wiki": () => importLazy(Promise.all([
    import("../../root/js/jquery/plugins/markitup/sets/wiki/set.js"),
    import("../../root/js/jquery/plugins/markitup/sets/wiki/style.css")
  ])),
  tabletools: () => importLazy(Promise.all([
    import("../../root/js/jquery/plugins/tabletools/media/js/TableTools.min.js"),
    import("../../root/js/jquery/plugins/tabletools/media/css/TableTools.css")
  ])),
  placeholder: () => importLazy(import("../../root/js/jquery/plugins/jquery.placeholder.min.js")),
  cytoscape_js: () => importLazy(import("../../root/js/jquery/plugins/cytoscapejs/cytoscape_min/2.5.0/cytoscape.min.js"), {
    globalName: 'cytoscape',
  }),
  cytoscape_js_arbor: () => importLazy(import("../../root/js/jquery/plugins/cytoscapejs/cytoscape_arbor/1.1.2/cytoscape-arbor.js")),
  cytoscape_js_dagre: () => importLazy(import("../../root/js/jquery/plugins/cytoscapejs/cytoscape_dagre/1.1.2/cytoscape-dagre.js")),
  qtip: () => importLazy(Promise.all([
    import("../../root/js/jquery/plugins/qtip2/2.2.0/jquery.qtip.min.js"),
    import("../../root/js/jquery/plugins/qtip2/2.2.0/jquery.qtip.min.css")
  ])),
  cytoscape_js_qtip: () => importLazy(import("../../root/js/jquery/plugins/cytoscapejs/cytoscape_js_qtip/2.2.5/cytoscape-qtip.js")),
  highcharts: () => importLazy(import("../../root/js/highcharts/4.1.9/highcharts.js")),
  highcharts_more: () => importLazy(import("../../root/js/highcharts/4.1.9/highcharts-more.js")),
  simple_statistics: () => importLazy(import("../../root/js/simple-statistics/1.0.1/simple_statistics.min.js"), {
    globalName: 'ss',
  }),  // statistics library in JS
  icheck: () => importLazy(Promise.all([
    import("../../root/js/jquery/plugins/icheck-1.0.2/icheck.min.js"),
    import("../../root/js/jquery/plugins/icheck-1.0.2/skins/square/aero.css")
  ]))
}

// LegacyPlugin.pStyle = {
//   dataTables: "jquery/plugins/dataTables/media/css/demo_table.css",
//   colorbox: "jquery/plugins/colorbox/colorbox/colorbox.css",
//   markitup: "jquery/plugins/markitup/skins/markitup/style.css",
//   "markitup-wiki": "jquery/plugins/markitup/sets/wiki/style.css",
//   tabletools: "jquery/plugins/tabletools/media/css/TableTools.css",
//   qtip: "jquery/plugins/qtip2/2.2.0/jquery.qtip.min.css",
//   icheck: "jquery/plugins/icheck-1.0.2/skins/square/aero.css"
// };

export {
  LegacyPlugin
};
