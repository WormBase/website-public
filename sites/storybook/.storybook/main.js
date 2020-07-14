const path = require('path');
const fs = require('fs');

module.exports = {
  stories: [
    '../../../sites/**/src/**/*.stories.[tj]s',
    '../../../packages/**/src/**/*.stories.[tj]s'
  ],
  webpackFinal: (config) => {
    const sitesPath = path.resolve(__dirname, '../../../sites');
    const packagesDir = path.resolve(__dirname, '../../../packages');
    config.module.rules[0].include = fs.readdirSync(sitesPath).map((dir) => path.resolve(sitesPath, dir));
    config.module.rules[0].exclude = fs.readdirSync(sitesPath).map((dir) => path.resolve(sitesPath, dir, 'node_modules'));
    console.dir(config, { depth: null });
    return config;
  },
};
