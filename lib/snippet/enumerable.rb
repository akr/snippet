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

  def each_with(*args)
    each_with_index {|v, i|
      yield v, *args.map {|arg| arg[i] }
    }
  end
end
