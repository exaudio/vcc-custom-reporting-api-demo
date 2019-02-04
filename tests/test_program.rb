require './lib/program.rb'
require 'test/unit'

class TestProgram < Test::Unit::TestCase
  def test_sample
    assert_equal(4, 2 + 2)
  end
end
