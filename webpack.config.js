var path = require('path');
var webpack = require('webpack');
var ExtractTextPlugin = require("extract-text-webpack-plugin");

module.exports = {
  // the base path which will be used to resolve entry points
  context: __dirname,

  // the main entry point for our application's frontend JS
  entry: './app/frontend/entry.js',

  output: {
    // this is our app/assets/javascripts directory, which is part of the Sprockets pipeline
    path: path.join(__dirname, 'app', 'assets', 'javascripts'),
    // the filename of the compiled bundle, e.g. app/assets/javascripts/bundle.js
    filename: 'bundle.js',
    // if the webpack code-splitting feature is enabled, this is the path it'll use to download bundles
    publicPath: '/assets',
  },

  resolve: {
    // tell webpack which extensions to auto search when it resolves modules. With this,
    // you'll be able to do `require('./utils')` instead of `require('./utils.js')`
    extensions: ['', '.js', '.coffee', '.css'],
    // by default, webpack will search in `web_modules` and `node_modules`. Because we're using
    // Bower, we want it to look in there too
    modulesDirectories: [ 'node_modules', 'bower_components' ],
  },

  plugins: [
    // we need this plugin to teach webpack how to find module entry points for bower files,
    // as these may not have a package.json file
    new webpack.ResolverPlugin([
      new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin('.bower.json', ['main'])
    ]),
    new ExtractTextPlugin("../stylesheets/bundle.css"),
    new webpack.ProvidePlugin({
      Promise: 'imports?this=>global!exports?global.Promise!es6-promise',
      fetch: 'imports?this=>global!exports?global.fetch!whatwg-fetch'
    }),
    new webpack.DefinePlugin({
      'process.env':{
        'NODE_ENV': JSON.stringify(process.env.NODE_ENV || 'development')
      }
    })
  ],

  module: {
    loaders: [
      { test: /\.coffee$/, loader: 'coffee-loader' },
      {
        test: /\.jsx?$/,
        exclude: /(node_modules|bower_components)/,
        loader: 'babel', // 'babel-loader' is also a legal name to reference
      },
      {
        test: /\.css$/,
        loader: ExtractTextPlugin.extract("style-loader", "css-loader")
      },
      { test: require.resolve("react"), loader: "expose?React" },
      { test: require.resolve("react-dom"), loader: "expose?ReactDOM" }
    ]
  }
};
