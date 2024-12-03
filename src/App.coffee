class App
  ###*
  # @param {fs} _fs Required lib
  # @param {path} _path Required lib
  # @param {Utils} utils My lib
  # @param {Formatter} formatter My lib
  # @param {PageFactory} pageFactory My lib
  # @param {HtmlToMarkdownConverter} converter HTML to Markdown converter implementation
  # @param {Logger} logger My lib
  ###
  constructor: (@_fs, @_path, @utils, @formatter, @pageFactory, @converter, @logger) ->
    return

  ###*
  # Converts HTML files to MD files.
  # @param {string} dirIn Directory to go through
  # @param {string} dirOut Directory where to place converted MD files
  ###
  convert: (dirIn, dirOut) ->
    filePaths = @utils.readDirRecursive dirIn
    pages = (@pageFactory.create filePath for filePath in filePaths when filePath.endsWith '.html')

    indexHtmlFiles = []
    for page in pages
      do (page) =>
        if page.fileName == 'index.html'
          indexHtmlFiles.push @_path.join page.space, 'index' # gitit requires link to pages without .md extension
        @convertPage page, dirIn, dirOut, pages

    @writeGlobalIndexFile indexHtmlFiles, dirOut if not @utils.isFile dirIn
    @logger.info 'Conversion done'


  ###*
  # Converts HTML file at given path to MD.
  # @param {Page} page Page entity of HTML file
  # @param {string} dirOut Directory where to place converted MD files
  ###
  convertPage: (page, dirIn, dirOut, pages) ->
    @logger.info 'Parsing ... ' + page.path
    rawText = page.getRawText pages
    text = page.getTextToConvert pages

    # Append the page project step (if present and valid) to the path
    matchprojectStep = text.match /<th[^>]*class="confluenceTh"[^>]*>\s*<p><strong>Project Step<\/strong><\/p>\s*<\/th>\s*<td[^>]*>\s*<p>(.*?)<\/p>\s*<\/td>/
    projectStepPath = ""
    if matchprojectStep
        projectStepPath = matchprojectStep[1].trim()
        if projectStepPath.includes("Example Discovery") or projectStepPath.includes("N/A") or projectStepPath.includes("n/a") or projectStepPath.length < 3
            console.warn("Project Step contains default values or n/a - reverted to default file path. Project Step was: '" + projectStepPath + "'")
            projectStepPath = ""
        else    
            projectStepPath = projectStepPath.split('/').join('\\').replace(/\s+/g, '-').toLowerCase() # Replace forward slashes with backslashes (VS coffeescript parser doesn't like regex)
            console.log("Project Step path found, appending to output path: '" + dirOut + projectStepPath)
            console.log("I.e.: '" + @_path.join dirOut, projectStepPath, page.space, page.fileNameNew )

    # Append the page chapter (if present and valid) to the path
    matchChapter = text.match /<th[^>]*class="confluenceTh"[^>]*>\s*<p><strong>Chapter<\/strong><\/p>\s*<\/th>\s*<td[^>]*>\s*<p>(.*?)<\/p>\s*<\/td>/
    chapterPath = ""
    if matchChapter
        chapterPath = matchChapter[1].trim()
        if chapterPath.includes("Example Discovery") or chapterPath.includes("N/A") or chapterPath.includes("n/a") or chapterPath.length < 3
            console.warn("Chapter path contains default values or n/a - reverted to default file path. Chapter was: '" + chapterPath + "'")
            chapterPath = ""
        else    
            chapterPath = chapterPath.split('/').join('\\').replace(/\s+/g, '-').toLowerCase() # Replace forward slashes with backslashes (VS coffeescript parser doesn't like regex)
            console.log("Chapter path found, appending to output path: '" + dirOut + chapterPath)
            console.log("I.e.: '" + @_path.join dirOut, chapterPath, page.space, page.fileNameNew )

    assetOutputFileName = @_path.join dirOut, page.space, page.fileNameNew
    fullOutFileName = @_path.join dirOut, page.space, "markdown", projectStepPath, chapterPath, page.fileNameNew

    @logger.info 'Making Markdown ... ' + fullOutFileName
    try
        @writeMarkdownFile text, rawText, fullOutFileName
        @utils.copyAssets @utils.getDirname(page.path), @utils.getDirname(assetOutputFileName)
        @logger.info 'Done\n'
    catch error
        @logger.error "Failed: #{error}\n"


  ###*
  # @param {string} text Makdown content of file
  # @param {string} fullOutFileName Absolute path to resulting file
  # @return {string} Absolute path to created MD file
  ###
  writeMarkdownFile: (text, rawText, fullOutFileName) ->
    fullOutDirName = @utils.getDirname fullOutFileName
    try
        @_fs.ensureDirSync fullOutDirName
    catch error
        @logger.error "Unable to create directory '#{fullOutDirName}': #{error}"
        throw error

    # Remove trailing hyphens ...yes, some pages have spaces on the end.
    fullOutFileName = fullOutFileName.replace /-+(\.[^\.]+)$/, '$1'
    @converter.convert text, rawText, fullOutFileName


  ###*
  # @param {array} indexHtmlFiles Relative paths of index.html files from all parsed Confluence spaces
  # @param {string} dirOut Absolute path to a directory where to place converted MD files
  ###
  writeGlobalIndexFile: (indexHtmlFiles, dirOut) ->
    globalIndex = @_path.join dirOut, 'index.md'
    $content = @formatter.createListFromArray indexHtmlFiles
    text = @formatter.getHtml $content
    @writeMarkdownFile text, "", globalIndex


module.exports = App
