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
  #   1st iteration: <1st value from each>, arg1[0], arg2[0], ...
  #   2nd iteration: <2nd value from each>, arg1[1], arg2[1], ...
  #   ...
  def each_with(*args)
    args = args.map {|arg| arg.to_ary }
    each_with_index {|v, i|
      yield v, *args.map {|arg| arg[i] }
    }
  end

  def shuffle
    r = self.to_a
    r.each_index {|i|
      j = i + rand(r.length - i)
      t = r[i]
      r[i] = r[j]
      r[j] = t
    }
    r
  end

  # each_coset gathers consecutive elements which the argument procedure returns a same value.
  #
  # If a regexp is given for the argument, 
  # matched substring is used for the value.
  # I.e. enum.each_const(regexp) means enum.each_const(lambda {|e| regexp =~ e; $& })
  #
  #   (1..10).each_coset(lambda {|e| e / 3 }) {|x| p x }
  #   #=> [1, 2]
  #   #   [3, 4, 5]
  #   #   [6, 7, 8]
  #   #   [9, 10]
  #
  #   # gather indented blocks.
  #   file.each_coset(lambda {|line| /\A\s/ =~ line }) {|x| pp x }
  #
  def each_coset(arg)
    if Regexp === arg
      regexp = arg
      arg = lambda {|e| regexp =~ e; $& }
    end
    prev_value = prev_elts = nil
    self.each {|e|
      v = arg.call(e)
      if prev_value == nil
        if v == nil
          yield [e]
        else
          prev_value = v
          prev_elts = [e]
        end
      else
        if v == nil
          yield prev_elts
          yield [e]
          prev_value = prev_elts = nil
        elsif prev_value == v
          prev_elts << e
        else
          yield prev_elts
          prev_value = v
          prev_elts = [e]
        end
      end
    }
    if prev_value != nil
      yield prev_elts
    end
  end

  # each_header gathers consecutive elements which begins the argument procedure returns true.
  #
  # If a regexp is given for the argument, 
  # matched substring is used for the value.
  # I.e. enum.each_header(regexp) means enum.each_header(lambda {|e| regexp =~ e; $& })
  #
  #   # parse a mbox format.
  #   open("mbox") {|f|
  #     f.each_header(/\AFrom /) {|mail| ... }
  #   }
  #
  #   # parse a ChangeLog
  #   open("ChangeLog") {|f|
  #     f.each_header(/\A\S/) {|entry| ... }
  #   }
  #
  def each_header(header_p)
    if Regexp === header_p
      regexp = header_p
      header_p = lambda {|e| regexp =~ e }
    end
    prev_elts = nil
    self.each {|e|
      if header_p.call(e)
        if prev_elts
          yield prev_elts
        end
        prev_elts = [e]
      else
        if prev_elts
          prev_elts << e
        else
          prev_elts = [e]
        end
      end
    }
    if prev_elts
      yield prev_elts
    end
  end

  # each_header gathers consecutive elements which ends the argument procedure returns true.
  #
  # If a regexp is given for the argument, 
  # matched substring is used for the value.
  # I.e. enum.each_trailer(regexp) means enum.each_trailer(lambda {|e| regexp =~ e; $& })
  #
  #   # split C functions (It assumes function ends with "}" at the beginning of a line.)
  #   open("foo.c") {|f|
  #     f.each_trailer(/\A\}/) {|fun| ... }
  #   }
  #
  def each_trailer(trailer_p)
    if Regexp === trailer_p
      regexp = trailer_p
      trailer_p = lambda {|e| regexp =~ e }
    end
    prev_elts = []
    self.each {|e|
      prev_elts << e
      if trailer_p.call(e)
        yield prev_elts
        prev_elts = []
      end
    }
    if !prev_elts.empty?
      yield prev_elts
    end
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
