require 'minitest/autorun'
require 'minitest/rspec_mocks'

module Minitest
  class Test
    include Minitest::RSpecMocks
  end
end

