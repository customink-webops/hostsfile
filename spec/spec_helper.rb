require 'chefspec'
require 'fauxhai'

# Require our libraries. They aren't actually loaded early enough to mock.
Dir['libraries/*'].each do |library|
  require File.expand_path(library)
end

$cookbook_paths = [
  File.expand_path('../../..', __FILE__),
  File.expand_path('../cookbooks', __FILE__)
]

RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end
