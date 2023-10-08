HtmlToMarkdownConverter = require './HtmlToMarkdownConverter'
TurndownService = require 'turndown'
TurndownPluginGfm = require 'joplin-turndown-plugin-gfm'

class TurndownConverter extends HtmlToMarkdownConverter
  constructor: (@_fs) ->
    super()

    options =
        headingStyle: 'atx'
        codeBlockStyle: 'fenced'

    @service = new TurndownService options
    @service.use(TurndownPluginGfm.gfm)

    return

  ###*
  # @param {string} html HTML input
  # @param {string} markdownPath Markdown output file
  ###
  convert: (html, markdownPath) ->
    try
        markdown = @service.turndown html
        @_fs.writeFileSync markdownPath, markdown, flag: 'w'
    catch error
        @logger.error "Unable to convert HTML using Turndown! #{error}"

    return

module.exports = TurndownConverter
