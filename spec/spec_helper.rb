require 'simplecov'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'YAML'
require 'Diffy'

SimpleCov.start { add_filter '/spec/' }

def show_diff(fixture, output)
  puts Diffy::Diff.new(fixture, output, source: 'files', context: 3).to_s(:color)
end
