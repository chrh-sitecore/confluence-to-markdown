global.chai = require 'chai'
global.assert = chai.assert

global._fs = require 'fs-extra'
global._childProcess = require 'node:child_process'
global._path = require 'node:path'
global._cheerio = require 'cheerio'

global.Logger = require '../src/Logger'
global.Utils = require '../src/Utils'
global.Formatter = require '../src/Formatter'
global.PageFactory = require '../src/PageFactory'
global.PandocConverter = require '../src/Converter/PandocConverter'
global.App = require '../src/App'
