require './init'


describe 'App', ->

  it 'testing run', ->
    pathResource = _path.join __dirname, 'assets'
    pathResult = _path.join __dirname, '../test-build/Markdown'
    try _rmdir.sync pathResult

    logger = new Logger Logger.WARNING

    utils = new Utils _fs, _path, _ncp, logger
    formatter = new Formatter _cheerio, utils, logger
    pageFactory = new PageFactory formatter, utils
    app = new App _fs, _exec, _path, _mkdirp, utils, formatter, pageFactory, logger
    app.convert pathResource, pathResult
