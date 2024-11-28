# Confluence to Markdown converter

Converts [Confluence HTML export](#conflhowto) to Markdown.


## Requirements

The Node.js runtime is required. Can be installed using winget:

```
winget install -e --id OpenJS.NodeJS.LTS
```

If you install Node.js, please ensure it's been added to `PATH`. You may need to start a new
terminal instance after installation, or reboot.


### Pandoc (optional)

Pandoc can be used as an _optional_ conversion method, in case the default Turndown method doesn't
produce the expected result. If so, install it by downloading the installer from [pandoc] and make
sure it's added to `PATH`. Check it by running:

```
pandoc --version
```

Please note that Turndown usually produces the best Markdown, so always start by using it.


## Usage

In the converter's directory using PowerShell:

```
.\ConvertTo-Markdown.ps1 -InputPath <exported html path> -OutputPath <markdown path> [-Converter <turndown|pandoc>] [-DeveloperPortalFolder <developer portal path>]
```

Or by invoking `npm` directly:

```
npm run start -- -i <exported html path> -o <markdown path> [-c <turndown|pandoc>] [-DeveloperPortalFolder <developer portal path>]
```

### Parameters

Parameter                   | Description
----------------------      | -----------
`<exported html path>`      | File or directory to convert with extracted Confluence HTML export.
`<markdown path>`           | Directory to where the output will be generated to. e.g. `output`
`<turndown\|pandoc>`        | Conversion method. Defaults to `turndown`.
`<developer portal path>`   | Sitecore specific: if specified then converted output will be copied to this directory. It should be the root of the developer portal repo. e.g. `e:\projects\developer-portal`

Example usage:
`.\ConvertTo-Markdown.ps1 -InputPath "e:\export" -OutputPath "output" -DeveloperPortalFolder "E:\projects\developer-portal"`

## Process description<a name="process-description"></a>

- Confluence page IDs in HTML file names and links are replaced with that pages' heading
- overall `index.md` is created linking all Confluence spaces - their indexes
- images and other inserted attachments are linked to generated markdown
  - whole `images` and `attachments` directories are copied to resulting directory
    - there is no checking done whether perticular file/image is used or not
- markdown links to internal pages are generated without the trailing **.md** extension to comply to [gitit] expectations
  - this can be changed by finding all occurances of `gitit requires link to pages without .md extension` in the `.coffee` files and adding the extension there.
  - or you can send a PR ;)
- the pandoc utility can accept quite a few options to alter its default behavior
  - those can be passed to it by adding them to `@outputTypesAdd`, `@outputTypesRemove`, `@extraOptions` properties in the [`App.coffee`](src/App.coffee) file
  - or you can send a PR ;)
  - here is the [list of options][pandoc-options] pandoc can accept
- throughout the application a single console logger is used, its default verbosity is set to INFO
  - you can change the verbosity to one of DEBUG, INFO, WARNING, ERROR levels in the [`Logger.coffee`](src/App.coffee) file
  - or you can send a PR ;)
- a series of formatter rules is applied to the HTML text of Confluence page for it to be converted properly
  - you can view and/or change them in the [`Page.coffee`](src/Page.coffee) file
  - the rules themselves are located in the [`Formatter.coffee`](src/Formatter.coffee) file

## Updates by Chris Howarth
Note: all these changes only work for and were only tested on the Turndown Converter
- Curly braces and angle brackets are now properly escaped (with backslashes)
  - This is because any loose `{ }` or `< >`  characters may break a markdown parser. 
  - They are allowed within code blocks. i.e. enclosed in backticks or triple backticks
- Confluence code blocks are now wrapped in code tags which the converter turns into MD code blocks
  - Defaults to csharp - not sure if it's possible to detect language in the exported HTML
- Style and script tags are removed as these generate invalid MD.
- CData is removed: these also cause issues with markdown parsing.
- Attachments section is removed: (`#attachments`)

### Sitecore specific updates
- AP Containers are removed (`.ap-container`)
- Additional optional parameter in the `ConvertTo-Markdown.ps1` PowerShell script to copy the exported pages and assets into another directory of your choosing (e.g. your learn/accelerate directory).
- addPageHeading method removed as we don't need this in the accelerate markdown.
- The raw confluence page html is additionally passed to the `TurndownConverter.coffee` class
  - This is then used to create and populate a YAML block at the top of the .md file for use with the developer portal
  - The YAML block additionally defines a breadcrumb, author and last updated date to help with review.

### Room for improvement
- The `TurndownConverter.coffee` class has several regex hacks added to massage the html into the right shape
  - Ideally these would be moved to the `Formatter.coffee` class
- The breadcrumb could be used to automatically define the directory structure for the Developer Portal
  - This would involve updating `@_fs.writeFileSync markdownPath, markdown, flag: 'w'` in `TurndownConverter.coffee`.
  - And also a lot of directory creation logic would need to be built.
- If you happen to find something not to your liking, you are welcome to send a PR. Some good starting points are mentioned in the [Process description](#process-description) section above. 


## Step by step guide for Confluence data export<a name="conflhowto"></a>

1. Go to the space and choose `Space tools > Content Tools` on the sidebar.
2. Choose Export. This option will only be visible if you have the **Export Space** permission.
3. Select HTML then choose Next.
4. Decide whether you need to customize the export:
   - Select Normal Export to produce an HTML file containing all the pages that you have permission to view.
   - Select Custom Export if you want to export a subset of pages, or to exclude comments from the export.
5. Extract ZIP file.

**WARNING**  
Please note that Blog will **NOT** be exported to HTML. You have to copy it manually or export it to XML or PDF. But those format cannot be processed by this utility.


# Attribution

Thanks to Eric White for a starting point. Thanks to JGM for the updated version.


[pandoc]: http://pandoc.org/installing.html
[pandoc-options]: http://hackage.haskell.org/package/pandoc
[gitit]: https://github.com/jgm/gitit/
