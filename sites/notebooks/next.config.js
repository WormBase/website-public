require('dotenv').config()

module.exports = {
	env: {
		GITHUB_CLIENT_ID: process.env.GITHUB_CLIENT_ID,
		REPO_FULL_NAME: process.env.REPO_FULL_NAME,
		BASE_BRANCH: process.env.BASE_BRANCH,
	},
	webpack: (config, { isServer }) => {
		// Fixes npm packages that depend on `fs` module
		if (!isServer) {
			config.node = {
				fs: 'empty'
			}
		}

		return config
	},
	// ...
}
