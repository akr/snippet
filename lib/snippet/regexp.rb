def Regexp.alt(*args)
  case args.length
  when 0
    /(?!)/
  when 1
    arg = args[0]
    if Regexp === arg
      arg
    elsif arg.respond_to? :to_str
      Regexp.new(Regexp.quote(arg.to_str))
    else
      raise TypeError, "cannot convert #{arg.class} to String"
    end
  else
    code = nil
    source = args.map {|arg|
      if Regexp === arg
        if arg.kcode
          if code && code != arg.kcode
            raise ArgumentError, "mixed kcode: #{args.inspect}"
          end
          code = arg.kcode
        end
        arg.to_s
      elsif arg.respond_to? :to_str
        Regexp.quote(arg.to_str)
      else
        raise TypeError, "cannot convert #{arg.class} to String"
      end
    }.join('|')

    Regexp.new(source, nil, code)
  end
end

class Regexp
  def disable_capture
    re = ''
    # xxx: not perfect. consider /[(]/.
    self.source.scan(/\\.|[^\\\(]+|\(\?|\(/m) {|s|
      if s == '('
        re << '(?:'
      else
        re << s
      end
    }
    Regexp.new(re, self.options, self.kcode)
  end

  def anchor(left_anchor=true, right_anchor=true)
    if left_anchor
      if right_anchor
        /\A#{self}\z/
      else
        /\A#{self}/
      end
    else
      if right_anchor
        /#{self}\z/
      else
        self
      end
    end
  end
end

if $0 == __FILE__
  require 'test/unit'

  class TestRegexpExt < Test::Unit::TestCase
    def test_alt
      assert_equal("(?!)", Regexp.alt.source)
      assert_equal(nil, Regexp.alt.kcode)

      assert_equal(nil, Regexp.alt(/a/, /b/).kcode)
      assert_equal('euc', Regexp.alt(/a/e, /b/).kcode)
      assert_equal('euc', Regexp.alt(/a/, /b/e).kcode)
      assert_raises(ArgumentError) { Regexp.alt(/a/e, /b/s) }

      assert_raises(TypeError) { Regexp.alt(1) }
      assert_raises(TypeError) { Regexp.alt(1, 2) }

      assert_instance_of(Regexp, Regexp.alt("a"))
      assert_instance_of(Regexp, Regexp.alt("*"))
      assert_instance_of(Regexp, Regexp.alt("*", "|"))

      assert_match(/\A#{Regexp.alt("*")}\z/, "*")
      assert_no_match(/\A#{Regexp.alt("*")}\z/, "a")
      assert_match(/\A#{Regexp.alt("*", "|")}\z/, "*")
      assert_match(/\A#{Regexp.alt("*", "|")}\z/, "|")
      assert_no_match(/\A#{Regexp.alt("*", "|")}\z/, "a")

      assert_match(/\A#{Regexp.alt(/a/i, /b/)}\z/, "A")
    end

    def test_union
      assert_equal("(?!)", Regexp.union.source)
      assert_equal(nil, Regexp.union.kcode)

      assert_equal(nil, Regexp.union(/a/, /b/).kcode)
      assert_equal('euc', Regexp.union(/a/e, /b/).kcode)
      assert_equal('euc', Regexp.union(/a/, /b/e).kcode)
      assert_raises(ArgumentError) { Regexp.union(/a/e, /b/s) }

      assert_raises(TypeError) { Regexp.union(1) }
      assert_raises(TypeError) { Regexp.union(1, 2) }

      assert_instance_of(Regexp, Regexp.union("a"))
      assert_instance_of(Regexp, Regexp.union("*"))
      assert_instance_of(Regexp, Regexp.union("*", "|"))

      assert_match(/\A#{Regexp.union("*")}\z/, "*")
      assert_no_match(/\A#{Regexp.union("*")}\z/, "a")
      assert_match(/\A#{Regexp.union("*", "|")}\z/, "*")
      assert_match(/\A#{Regexp.union("*", "|")}\z/, "|")
      assert_no_match(/\A#{Regexp.union("*", "|")}\z/, "a")

      assert_match(/\A#{Regexp.union(/a/i, /b/)}\z/, "A")
    end

    def test_anchor
      assert_no_match(/b/.anchor(true, true), "abc")
      assert_no_match(/b/.anchor(true, true), "ab")
      assert_no_match(/b/.anchor(true, true), "bc")
      assert_match(/b/.anchor(true, true), "b")

      assert_no_match(/b/.anchor(false, true), "abc")
      assert_match(/b/.anchor(false, true), "ab")
      assert_no_match(/b/.anchor(false, true), "bc")
      assert_match(/b/.anchor(false, true), "b")

      assert_no_match(/b/.anchor(true, false), "abc")
      assert_no_match(/b/.anchor(true, false), "ab")
      assert_match(/b/.anchor(true, false), "bc")
      assert_match(/b/.anchor(true, false), "b")

      assert_match(/b/.anchor(false, false), "abc")
      assert_match(/b/.anchor(false, false), "ab")
      assert_match(/b/.anchor(false, false), "bc")
      assert_match(/b/.anchor(false, false), "b")
    end

  end
end
