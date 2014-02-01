require 'bundler/setup'

namespace :style do
  require 'foodcritic'
  desc 'Run Chef style checks'
  FoodCritic::Rake::LintTask.new(:chef)
end

desc 'Run all style checks'
task style: ['style:chef']

require 'kitchen'
desc 'Run Test Kitchen integration tests'
task :integration do
  Kitchen.logger = Kitchen.default_file_logger
  Kitchen::Config.new.instances.each do |instance|
    instance.test(:always)
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:unit) do |t|
  t.rspec_opts = ['--color --format progress']
end

# We cannot run Test Kitchen on Travis CI yet...
namespace :travis do
  desc 'Run tests on Travis'
  task ci: ['unit', 'style']
end

# The default rake task should just run it all
task default: ['travis:ci', 'integration']
