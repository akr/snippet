module Enumerable
  def zipp
    len = nil
    result = nil
    first = true
    self.each {|objs|
      if first
        result = []
        objs.each {|obj| result << [obj]}
        len = result.length
        first = false
      else
        i = -1
        objs.each_with_index {|obj, i| result[i] << obj}
        raise ArgumentError.new("different number of objects in each enum") unless i + 1 == len
      end
    }
    result
  end

  def map_with_index
    result = []
    i = 0
    self.each {|elt|
      result << yield(elt, i)
      i += 1
    }
    result
  end

  # each_with iterates self with elements of arguments as arrays.
  # For each iteration of self, each_with yields a value yielded by +each+
  # and values taken from arguments:
  #
  #   1st iteration: <value from each>, arg1[0], arg2[0], ...
  #   2nd iteration: <value from each>, arg1[1], arg2[1], ...
  #   ...
  def each_with(*args)
    args = args.map {|arg| arg.to_ary }
    each_with_index {|v, i|
      yield v, *args.map {|arg| arg[i] }
    }
  end
end

if $0 == __FILE__
  require 'test/unit'

  class TestEachWith < Test::Unit::TestCase
    def test_3x3
      result = [[1,4,7], [2,5,8], [3,6,9]]
      (1..3).each_with([4,5,6],[7,8,9]) {|*v|
        assert_equal(result.shift, v)
      }
    end

    def test_short_array
      result = [[1,4], [2,5], [3,nil]]
      (1..3).each_with([4,5]) {|*v|
        assert_equal(result.shift, v)
      }
    end

    def test_long_array
      result = [[1,4], [2,5], [3,6]]
      (1..3).each_with([4,5,6,7]) {|*v|
        assert_equal(result.shift, v)
      }
    end

  end
end
