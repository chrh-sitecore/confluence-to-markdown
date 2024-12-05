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
  # @param {string} rawHtml Markdown output file
  # @param {string} markdownPath Markdown output file
  ###
  convert: (html, rawHtml, markdownPath) ->
    try
        # Remove Recipe table
        html = html.replace(new RegExp('<tr>.*?<th[^>]*>.*?On this page.*?</th>.*?</tr>', 'gs'), '')

        markdown = @service.turndown html
        
        # Step 1: Match and preserve content inside code blocks
        codeBlockRegex = /```[\s\S]*?```/g
        codeBlocks = []  # Initialize codeBlocks array

        # Replace code blocks with placeholders
        markdown = markdown.replace(codeBlockRegex, (match) ->
          codeBlocks.push(match)  # Store code block in array
          "[CODEBLOCK#{codeBlocks.length - 1}]"  # Placeholder for code block
        )

        # Step 2: Escape <, >, {, and } outside of code blocks
        markdown = markdown.replace /</g, '\\<'
        markdown = markdown.replace />/g, '\\>'
        markdown = markdown.replace /\{/g, '\\{'
        markdown = markdown.replace /\}/g, '\\}'

        # Step 3: Restore code blocks
        codeBlocks.forEach (block, index) ->
          placeholder = "[CODEBLOCK#{index}]"
          markdown = markdown.replace(placeholder, block)  # Replace placeholder with original code block content

        # Replace links starting with 'images'
        markdown = markdown.replace /!\[([^\]]+)\]\(images([^)]*)\)/g, (match, altText, path) -> "![#{altText}](/images/learn/accelerate/content-hub/img#{path})"

        # Replace links starting with 'attachments'
        markdown = markdown.replace /!\[([^\]]+)\]\(attachments([^)]*)\)/g, (match, altText, path) -> "![#{altText}](/images/learn/accelerate/content-hub/attachments#{path})"

        # Regex to match the breadcrumb items (links inside <a> tags)
        # Extract the HTML inside the breadcrumb section using regex
        breadcrumbSectionHtml = rawHtml.match /<div id="breadcrumb-section">([\s\S]*?)<\/div>/i

        # Check if we found the breadcrumb section, otherwise return empty string
        if breadcrumbSectionHtml
          # Match all <a> tags inside the breadcrumb section
          breadcrumbMatches = breadcrumbSectionHtml[0].match /<a [^>]*>(.*?)<\/a>/g

          # Extract the text from each match
          breadcrumbText = (match.match(/>(.*?)<\/a>/)[1] for match in breadcrumbMatches)

          # Join the breadcrumb items into a single string separated by " > "
          breadcrumbString = breadcrumbText.join(' > ')

          # Extract the text from each match
          breadcrumbText = (match.match(/>(.*?)<\/a>/)[1] for match in breadcrumbMatches)

          # Join the breadcrumb items into a single string separated by " > "
          breadcrumbString = breadcrumbText.join(' > ')

        # Extract the title-text content using a regular expression
        titleMatch = rawHtml.match /<span id="title-text">\s*([\s\S]*?)\s*<\/span>/
        rawTitle = if titleMatch then titleMatch[1]?.trim() else null  # Use only the captured group

        # Extract content after the semicolon
        title = if rawTitle? and rawTitle.includes(':')
          rawTitle.split(':')[1]?.trim()  # Split by colon and take the part after
        else
          null

        # Match the table with class "confluenceTable"
        tableMatch = rawHtml.match /<table[^>]*class="confluenceTable"[^>]*>([\s\S]*?)<\/table>/
        if tableMatch
          tableContent = tableMatch[1]  # Extract the content inside the table

          # Match all <tr> rows in the table
          rows = tableContent.match /<tr>([\s\S]*?)<\/tr>/g
          if rows
            for row in rows
              # Match the <th> and <td> in the same <tr>
              match = row.match /<th[^>]*>([\s\S]*?)<\/th>[\s\S]*?<td[^>]*>([\s\S]*?)<\/td>/
              if match
                thContent = match[1]
                  .replace /<[^>]*>/g, ''  # Strip all tags
                  .replace /\s+/g, ' '  # Normalize whitespace
                  .trim()  # Remove leading/trailing whitespace

                if thContent.toLowerCase() == 'description'  # Check if <th> contains 'Description'
                  description = match[2]
                    .replace /<[^>]*>/g, ''  # Strip all tags
                    .replace /\s+/g, ' '  # Normalize whitespace
                    .trim()  # Remove leading/trailing whitespace

        # Extract the author using a regular expression
        authorMatch = rawHtml.match /<span class="author">\s*(.*?)\s*<\/span>/
        author = authorMatch?[1] # Extract the first capturing group (author name)

        # Extract the date using a regular expression
        dateMatch = rawHtml.match /on\s([\d]{2}\s\w+,\s\d{4})/
        rawDate = dateMatch?[1] # Extract the first capturing group (date)

        # Convert the date to YYYY-MM-DD format
        formattedDate = if rawDate?
            new Date(rawDate.replace ',', '' ).toISOString().split('T')[0]
        else
            null

        # Extract audience
        matchAudience = rawHtml.match /<th[^>]*class="confluenceTh"[^>]*>\s*<p><strong>Reference Audience<\/strong><\/p>\s*<\/th>\s*<td[^>]*>\s*<p>(.*?)<\/p>\s*<\/td>/
        audience = ""
        if matchAudience
            audience = matchAudience[1].trim()

        yamlHeader = """
        ---
        title: '#{title}'
        description: '#{description}'
        hasSubPageNav: true
        hasInPageNav: true
        area: ['accelerate']
        lastUpdated: '#{formattedDate}'
        breadcrumb: '#{breadcrumbString}'
        author: '#{author}'
        audience: '#{audience}'
        ---

        """
        markdown = yamlHeader + markdown

        @_fs.writeFileSync markdownPath, markdown, flag: 'w'
    catch error
        console.error error

    return

module.exports = TurndownConverter
