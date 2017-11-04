import React from 'react';
import ReactDOM from 'react-dom';
import './index.css';
import './legacy/css/jquery-ui.min.css';
import './legacy/css/main.css';
import './legacy/js/wormbase.js';
import App from './App';
import registerServiceWorker from './registerServiceWorker';

ReactDOM.render(<App />, document.getElementById('root'));
registerServiceWorker();
