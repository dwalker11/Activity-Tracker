const path = require('path');
const webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const CleanWebpackPlugin = require('clean-webpack-plugin');


module.exports = {
	context: path.resolve(__dirname, 'src'),

	entry: './index.js',

	output: {
		path: path.resolve(__dirname, 'dist'),
		filename: 'scripts/bundle.js'
	},

	module: {
		rules: [
			{
				test: /\.elm$/,
				exclude: [/elm-stuff/, /node_modules/],
				use: ['elm-webpack-loader']
			},
			{
				test: /\.scss$/,
				use: ExtractTextPlugin.extract({
					fallback: 'style-loader',
					use: ['css-loader', 'postcss-loader', 'sass-loader']
				})
			}
		]
	},

	plugins: [
		new webpack.ProvidePlugin({
			$: 'jquery',
			jQuery: 'jquery',
			'window.jQuery': 'jquery',
			Popper: ['popper.js', 'default']
		}),
		new CleanWebpackPlugin(['dist'], {
			exclude: ['index.html']
		}),
		new ExtractTextPlugin({
			filename: 'styles/main.css'
		})
	],

	devServer: {
		contentBase: './dist'
	}
}
