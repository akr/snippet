class String
  def begins_with?(prefix)
    return self[0, prefix.length] == prefix
  end

  def ends_with?(suffix)
    suffix_length = suffix.length
    return suffix_length == 0 || self[-suffix_length, suffix_length] == suffix
  end
end

if __FILE__ == $0
  require 'runit/testcase'
  require 'runit/cui/testrunner'

  class StringSnippetTest < RUNIT::TestCase
    def test_begins_with?
      assert_equal(true, "".begins_with?(""))
      assert_equal(false, "".begins_with?("a"))
      assert_equal(true, "abc".begins_with?(""))
      assert_equal(true, "abc".begins_with?("abc"))
      assert_equal(false, "abc".begins_with?("abcd"))
      assert_equal(false, "abc".begins_with?("bc"))
    end

    def test_ends_with?
      assert_equal(true, "".ends_with?(""))
      assert_equal(false, "".ends_with?("a"))
      assert_equal(true, "abc".ends_with?(""))
      assert_equal(true, "abc".ends_with?("c"))
      assert_equal(true, "abc".ends_with?("abc"))
      assert_equal(false, "abc".ends_with?("0abc"))
      assert_equal(false, "abc".ends_with?("ab"))
    end
  end

  RUNIT::CUI::TestRunner.run(StringSnippetTest.suite)
end
