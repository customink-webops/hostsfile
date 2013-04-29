require 'chefspec'
require 'fauxhai'

lib = File.expand_path('../../libraries', __FILE__)
$:.unshift(lib) unless $:.include?(lib)
require 'entry'
require 'manipulator'

$cookbook_paths = [
  File.expand_path('../../..', __FILE__),
  File.expand_path('../cookbooks', __FILE__)
]

RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end
