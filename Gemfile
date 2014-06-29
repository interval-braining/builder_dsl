source 'https://rubygems.org'

gemspec

group :doc do
  gem 'yard', require: false
end

group :test do
  gem 'coveralls', :require => false
  gem 'faker'
  gem 'minitest'
  gem 'mocha', :require => false
  gem 'shoulda-context'
end

# Dev and test gems not needed for CI
unless ENV['CI']
  group :development, :test do
    gem 'guard'
    gem 'guard-minitest'
    gem 'pry-debugger', :platforms => :mri
  end
end
