class Page


  constructor: (fullPath, @formatter, @utils) ->
    @path = fullPath
    @init()


  init: () ->
    @fileName = @utils.getBasename @path
    @fileBaseName = @utils.getBasename @path, '.html'
    @filePlainText = @utils.readFile @path
    @$ = @formatter.load @filePlainText
    @content = @$.root()
    @heading = @getHeading()
    @fileNameNew = @getFileNameNew()
    @space = @utils.getBasename @utils.getDirname @path
    @spacePath = @getSpacePath()


  getSpacePath: () ->
    '../' + @utils.sanitizeFilename(@space) + '/' + @fileNameNew


  getFileNameNew: () ->
    return 'index.md' if @fileName == 'index.html'
    @utils.sanitizeFilename(@heading) + '.md'


  getHeading: () ->
    title = @content.find('title').text()
    if @fileName == 'index.html'
      title
    else
      indexName = @content.find('#breadcrumbs .first').text().trim()
      title.replace indexName + ' : ', ''


  ###*
  # Converts HTML file at given path to MD formatted text.
  # @return {string} Content of a file parsed to MD
  ###
  getTextToConvert: (pages) ->
    content = @formatter.getRightContentByFileName @content, @fileName
    content = @formatter.removeAttachmentsSection content
    content = @formatter.fixHeadline content
    content = @formatter.fixIcon content
    content = @formatter.fixEmptyLink content
    content = @formatter.fixEmptyHeading content
    content = @formatter.fixPreformattedText content
    content = @formatter.fixImageWithinSpan content
    content = @formatter.removeArbitraryElements content
    content = @formatter.fixArbitraryClasses content
    content = @formatter.fixAttachmentWrapper content
    content = @formatter.fixPageLog content
    content = @formatter.wrapCodeBlocks content
    content = @formatter.removeApScriptElements content
    content = @formatter.removeStyleTags content
    content = @formatter.fixLocalLinks content, @space, pages
    if @fileName == 'index.html'
      content = @formatter.fixDuplicateUnorderedListSiblings content
    @formatter.getHtml content

  ###*
  # Converts HTML file at given path to MD formatted text without removing any elements.
  # @return {string} Content of a file parsed to MD
  ###
  getRawText: (pages) ->
    content = @formatter.getPageMeta @content, @fileName 
    @formatter.getHtml content

module.exports = Page
