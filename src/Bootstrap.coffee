class Bootstrap

  _fs = require 'fs-extra'
  _childProcess = require 'node:child_process'
  _path = require 'node:path'
  _cheerio = require 'cheerio'

  Utils = require './Utils'
  Logger = require './Logger'
  Formatter = require './Formatter'
  App = require './App'
  PageFactory = require './PageFactory'
  PandocConverter = require './Converter/PandocConverter'

  ###*
  # @param {string} pathResource Directory with HTML files or one file. Can be nested.
  # @param {string|void} pathResult Directory where MD files will be generated to. Current dir will be used if none given.
  ###
  run: (pathResource, pathResult = '') ->
    pathResource = _path.resolve pathResource
    pathResult = _path.resolve pathResult

    logger = new Logger Logger.INFO
    utils = new Utils _fs, _path, logger
    formatter = new Formatter _cheerio, utils, logger
    pageFactory = new PageFactory formatter, utils
    converter = new PandocConverter _childProcess, _fs, _path
    app = new App _fs, _path, utils, formatter, pageFactory, converter, logger

    logger.info 'Using source: ' + pathResource
    logger.info 'Using destination: ' + pathResult

    app.convert pathResource, pathResult


module.exports = Bootstrap
