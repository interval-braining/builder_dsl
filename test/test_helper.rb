if ENV['CI']
  require 'coveralls'
  Coveralls.wear!
end

require 'minitest/autorun'
require 'minitest/unit'
require 'mocha/setup'
require 'shoulda/context'
require 'builder_dsl'
