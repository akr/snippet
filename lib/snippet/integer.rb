class Integer
=begin
--- Integer#even?
--- Integer#odd?
    is a predicate which test self is even or odd number.
=end
  def even?
    return (self & 1) == 0
  end

  def odd?
    return (self & 1) == 1
  end

=begin
--- Integer#hex
    same as to_s(16)
=end
  def hex
    return to_s(16)
  end
end

if __FILE__ == $0
  require 'runit/testcase'
  require 'runit/cui/testrunner'

  class IntegerSnippetTest < RUNIT::TestCase
    def test_even?
      assert_equal(false, -1073741825.even?)
      assert_equal(true,  -1073741824.even?)
      assert_equal(false, -1073741823.even?)
      assert_equal(true,  -2.even?)
      assert_equal(false, -1.even?)
      assert_equal(true,  0.even?)
      assert_equal(false, 1.even?)
      assert_equal(true,  2.even?)
      assert_equal(false, 1073741823.even?)
      assert_equal(true,  1073741824.even?)
      assert_equal(false, 1073741825.even?)
    end

    def test_odd?
      assert_equal(true,  -1073741825.odd?)
      assert_equal(false, -1073741824.odd?)
      assert_equal(true,  -1073741823.odd?)
      assert_equal(false, -2.odd?)
      assert_equal(true,  -1.odd?)
      assert_equal(false, 0.odd?)
      assert_equal(true,  1.odd?)
      assert_equal(false, 2.odd?)
      assert_equal(true,  1073741823.odd?)
      assert_equal(false, 1073741824.odd?)
      assert_equal(true,  1073741825.odd?)
    end

    def test_hex
      assert_equal("0", 0.hex)
      assert_equal("10", 16.hex)
      assert_equal("-10", -16.hex)
    end
  end

  RUNIT::CUI::TestRunner.run(IntegerSnippetTest.suite)
end

