require 'simplecov'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'YAML'

SimpleCov.start do
  add_filter '/spec/'
end
