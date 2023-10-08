HtmlToMarkdownConverter = require './HtmlToMarkdownConverter'

class PandocConverter extends HtmlToMarkdownConverter
  # @link http://hackage.haskell.org/package/pandoc For options description
  @outputTypesAdd = [
    'gfm' # Use GitHub-Flavored Markdown
  ]

  @outputTypesRemove = [
    'raw_html' # Don't use HTML tags in markdown
  ]

  @extraOptions = [
    '--markdown-headings=atx' # Setext-style headers (underlined) | ATX-style headers (prefixed with hashes)
  ]

  constructor: (@_childProcess, @_fs, @_path) ->
    super()

    typesAdd = PandocConverter.outputTypesAdd.join '+'
    typesRemove = PandocConverter.outputTypesRemove.join '-'
    typesRemove = if typesRemove then '-' + typesRemove else ''
    types = typesAdd + typesRemove
    @pandocOptions = [
      if types then '-t ' + types else ''
      PandocConverter.extraOptions.join ' '
    ].join ' '
    return

  ###*
  # @param {string} html HTML input
  # @param {string} markdownPath Markdown output file
  ###
  convert: (html, markdownPath) ->
    tempInputFile = markdownPath + '~'
    @_fs.writeFileSync tempInputFile, html, flag: 'w'

    markdownDirName = @_path.dirname markdownPath

    try
        command = "pandoc -f html #{@pandocOptions} -o \"#{markdownPath}\" \"#{tempInputFile}\""
        execOptions =
            cwd: markdownDirName
            stdio: 'pipe'
        output = @_childProcess.execSync command, execOptions
    catch error
        @logger.error "Unable to execute pandoc! #{error}"

    @_fs.unlinkSync tempInputFile

    return

module.exports = PandocConverter
