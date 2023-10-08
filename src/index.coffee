{ Command, Option } = require('commander');
Bootstrap = require './Bootstrap'

# Command line interface
program = new Command

program
  .requiredOption('-i, --input <path>', 'input directory (Confluence HTML)')
  .requiredOption('-o, --output <path>', 'output directory (Markdown)')
  .addOption(new Option('-c, --converter <type>', 'converter type')
    .choices(['pandoc', 'turndown'])
    .default('turndown')
    .makeOptionMandatory());

program.parse()
options = program.opts()

bootstrap = new Bootstrap
bootstrap.run options.input, options.output, options.converter
