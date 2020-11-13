require 'simplecov'
require 'active_support'

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