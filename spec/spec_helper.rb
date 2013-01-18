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
