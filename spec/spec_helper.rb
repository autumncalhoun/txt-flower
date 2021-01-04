require 'simplecov'
require 'csv'
require 'active_support'
require 'active_support/core_ext'
require 'YAML'

SimpleCov.start do
  add_filter '/spec/'
end

# TODO: find out why this throws permission errors
# RSpec.configure do |config|
#   config.after(:suite) do
#     Dir['spec/tmp'].each do |file|
#       File.delete(file)
#     end
#   end
# end
