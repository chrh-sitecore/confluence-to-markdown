class HtmlToMarkdownConverter
  constructor: ->
    return

  ###*
  # @param {string} html HTML input
  # @param {string} markdownPath Markdown output file
  ###
  convert: (html, markdownPath) ->
    throw new Error("Abstract method called with html = #{html}, markdownPath = #{markdownPath}")

module.exports = HtmlToMarkdownConverter
