def Regexp.alt(*args)
  case args.length
  when 0
    /(?!)/
  when 1
    args[0]
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
      else
        Regexp.quote(arg)
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
    end
  end
end
