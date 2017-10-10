const path = require('path');
const webpack = require('webpack');


module.exports = {
	context: path.resolve(__dirname, 'src'),

	entry: './index.js',

	output: {
		path: path.resolve(__dirname, 'dist'),
		filename: 'bundle.js'
	},

	module: {
		rules: [
			{
				test: /.scss$/,
				use: [
					'style-loader',
					'css-loader',
					'postcss-loader',
					'sass-loader'
				]
			}
		]
	},

	plugins: [
		new webpack.ProvidePlugin({
			$: 'jquery',
			jQuery: 'jquery',
			'window.jQuery': 'jquery',
			Popper: ['popper.js', 'default']
		})
	],

	devServer: {
		contentBase: './dist'
	}
}

