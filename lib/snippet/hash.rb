class Hash
=begin
--- Hash#fetch!(key, default)
--- Hash#fetch!(key) {|key| ... }
    returns a corresponding value of ((|key|)) in the hash.
    If the hash has no corresponding value,
    ((|default|)) or evaluated value of the block is assigned with ((|key|)) in
    the hash, then the assigned value is returned.

    See also ((<ruby-dev:13982>)).
=end
  def fetch!(key, *rest)
    len1 = 1 + rest.length
    len2 = block_given? ? 1 : 2
    if len1 != len2
      raise ArgumentError.new("wrong number of arguments(#{len1} for #{len2})")
    end

    self.fetch(key) {|k|
      if block_given?
        self[key] = yield k
      else
        self[key] = rest.first
      end
    }
  end
end

if __FILE__ == $0
  require 'test/unit'

  class HashSnippetTest < Test::Unit::TestCase
    def test_fetch!
      h = {1=>2, 3=>4}
      assert_equal(6, h.fetch!(5, 6))
      assert_equal(6, h[5])
      assert_equal(8, h.fetch!(7) { 8 })
      assert_equal(8, h[7])
      assert_raises(ArgumentError) { h.fetch!(1) }
      assert_raises(ArgumentError) { h.fetch!(1, 2) { 3 } }
      assert_raises(ArgumentError) { h.fetch!(2) }
      assert_raises(ArgumentError) { h.fetch!(2, 2) { 3 } }
    end
  end
end

