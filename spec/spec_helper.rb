require "minitest/autorun"
require "minitest/rspec_mocks"

# Add the spec directory to LOAD_PATH
$LOAD_PATH.unshift(File.expand_path("..", __FILE__))
# Add the project root directory to LOAD_PATH
$LOAD_PATH.unshift(File.expand_path("../..", __FILE__))

module Minitest
  # Reopen Test class to include RSpec Mocks
  class Test
    include Minitest::RSpecMocks
  end
end

