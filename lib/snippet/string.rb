class String
=begin
--- String#begins_with?(prefix)
    is a predicate which returns true if the string begins with ((|prefix|)).

--- String#ends_with?(suffix)
    is a predicate which returns true if the string ends with ((|suffix|)).
=end
  def begins_with?(prefix)
    return self[0, prefix.length] == prefix
  end

  def ends_with?(suffix)
    suffix_length = suffix.length
    return suffix_length == 0 || self[-suffix_length, suffix_length] == suffix
  end

  def expand_tab!
    self.gsub!(/([^\t]{8})|([^\t]*)\t/n) {[$+].pack("A8")}                  
    nil
  end

  def expand_tab
    result = dup
    result.expand_tab!
    result
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

    def test_expand_tab
      assert_equal("a", "a".expand_tab)
      assert_equal("        ", "\t".expand_tab)
      assert_equal("a       ", "a\t".expand_tab)
      assert_equal("aaaaaaa ", "aaaaaaa\t".expand_tab)
      assert_equal("aaaaaaaa        ", "aaaaaaaa\t".expand_tab)
      assert_equal("aaaaaaaaa       ", "aaaaaaaaa\t".expand_tab)
      assert_equal("a       aa      a", "a\taa\ta".expand_tab)
    end
  end

  RUNIT::CUI::TestRunner.run(StringSnippetTest.suite)
end
