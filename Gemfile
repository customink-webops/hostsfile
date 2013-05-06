source 'https://rubygems.org'

gem 'chef',       ENV['CHEF_VERSION'] || '~> 11.0.0'
gem 'yard',       '~> 0.8.6'

group :test do
  gem 'chefspec',     '~> 1.0.0'
  gem 'strainer',     '~> 2.0.0'
  gem 'test-kitchen', '~> 1.0.0.alpha'
end

group :integration do
  gem 'berkshelf',          '~> 1.0'
  gem 'test-kitchen',       '~> 1.0.0.alpha'
  gem 'kitchen-vagrant',    '~> 0.9.0'
end
