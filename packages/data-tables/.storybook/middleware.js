const { createProxyMiddleware } = require('http-proxy-middleware');

const { proxy: proxyConfigs } = require('../package.json');

module.exports = router =>
    router.use('/rest', createProxyMiddleware({
      target: 'https://wormbase.org',
      changeOrigin: true
    }))
