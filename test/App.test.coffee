require './init'


describe 'App', ->

  it 'testing run', ->
    pathResource = _path.join __dirname, 'assets'
    pathResult = _path.join __dirname, '../test-build/Markdown'
    try _fs.removeSync pathResult

    logger = new Logger Logger.WARNING

    utils = new Utils _fs, _path, logger
    formatter = new Formatter _cheerio, utils, logger
    pageFactory = new PageFactory formatter, utils
    converter = new TurndownConverter _fs
    app = new App _fs, _path, utils, formatter, pageFactory, converter, logger
    app.convert pathResource, pathResult
