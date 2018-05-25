# txt-flower
This is a formatter for creating styled, flow-able text from a CSV data file. Flow the text into an InDesign document.

## Getting Started
```
irb -r ./flower.rb
Flower.new
```

For development, reload the file each time you make changes to it:
`load ".flower.rb"`

## Generate tagged text

Create a new flow-er based on the entity that needs it:
`sample = EFA.new`
Passing no file names will generate every file available for that entity.

Generate the tagged text:
`sample.generate_text`
