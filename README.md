# txt-flower

This is a formatter for creating styled, flow-able text from a CSV data file. Flow the text into an InDesign document.

## Generate tagged text

Start the CLI and follow the prompts

```
ruby './lib/flower.rb'
```

## Development

Each module represents a separate set of generators, which are based on specific business requirements.

For each module, you'll need:

- a yml file defining your validation criteria
- a CLI class that knows how to load your yml template and generate each file
- a generator class for each file
- a Rakefile entry to generate fixtures for each tagged text file represented in your specs

## Testing

- For new specs or changing requirements, generate your fixtures from the Rake file

```
$ rake test:update_fixtures_efa
```

- To help debug spec failures, there is a `show_diff` method that will print a diff of two files.
