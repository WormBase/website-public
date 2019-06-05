import './index.css';
import '../../root/css/jquery-ui.min.css';
import '../../root/css/main.css';

function main(err) {
  require('../../root/js/wormbase.js');
  // Initiate all other code paths.
  // If there's an error loading the polyfills, handle that
  // case gracefully and track that the error occurred.
}

function browserSupportsAllFeatures() {
  return window.Promise && window.fetch && window.Symbol;
}

function loadScript(src, done) {
  var js = document.createElement('script');
  js.src = src;
  js.onload = function() {
    done();
  };
  js.onerror = function() {
    done(new Error('Failed to load script ' + src));
  };
  document.head.appendChild(js);
}

if (browserSupportsAllFeatures()) {
  // Browsers that support all features run `main()` immediately.
  main();
} else {
  // All other browsers loads polyfills and then run `main()`.
  loadScript(
    'https://cdn.polyfill.io/v2/polyfill.min.js?features=default-3.6,fetch',
    main
  );
}
