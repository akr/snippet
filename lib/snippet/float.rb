class Float
  FLT_RADIX = 2

  def split
    fractional = []
    f, exp = Math.frexp(self)

    if f < 0
      sign = '-'
      f = -f
    elsif f > 0
      sign = '+'
    else
      if 1.0 / self < 0
	sign = '-'
	f = -f
      else
	sign = '+'
      end
    end

    while f != 0
      f *= FLT_RADIX

      # xxx: modf should be used.
      d = f.to_i
      f -= d

      fractional << d
    end

    [sign, fractional, exp]
  end

  def to_bin
    sign, fractional, exp = self.split
    sign = '' if 0 < self && sign == '+'
    if fractional.empty?
      rest = "0"
    elsif exp == fractional.length
      rest = "#{fractional}"
    elsif 0 < exp && exp < fractional.length
      rest = "#{fractional[0...exp]}.#{fractional[exp..-1]}"
    elsif exp == 0
      rest = "0.#{fractional}"
    elsif fractional.length == 1
      top = fractional.first
      rest = "#{top}p#{exp-1}"
    elsif !fractional.empty?
      top = fractional.shift
      rest = "#{top}.#{fractional}p#{exp-1}"
    else
      rest = "0.#{fractional}p#{exp}"
    end

    "#{sign}0b#{rest}"
  end

  def to_hex
    sign, fractional_bin, exp = self.split

    exp, mod = exp.divmod(4)
    if mod != 0
      exp += 1
      (4 - mod).times {
        fractional_bin.unshift 0
      }
    end

    until fractional_bin.length % 4 == 0
      fractional_bin << 0
    end

    fractional = []
    until fractional_bin.empty?
      fractional << sprintf("%x", fractional_bin[0] * 8 + fractional_bin[1] * 4 + fractional_bin[2] * 2 + fractional_bin[3])
      fractional_bin[0, 4] = []
    end

    sign = '' if 0 < self && sign == '+'
    if fractional.empty?
      rest = "0"
    elsif exp == fractional.length
      rest = "#{fractional}"
    elsif 0 < exp && exp < fractional.length
      rest = "#{fractional[0...exp]}.#{fractional[exp..-1]}"
    elsif exp == 0
      rest = "0.#{fractional}"
    elsif fractional.length == 1
      top = fractional.first
      rest = "#{top}p#{exp-1}"
    elsif !fractional.empty?
      top = fractional.shift
      rest = "#{top}.#{fractional}p#{exp-1}"
    else
      rest = "0.#{fractional}p#{exp}"
    end
    "#{sign}0x#{rest}"
  end

  def next
    raise FloatDomainError, "No next value for NaN" if self.nan?
    raise FloatDomainError, "No next value for infinite" if self.infinite?
    inc = 1.0
    if self + inc == self
      begin
	inc *= 2
      end while self + inc == self
    else
      while self + (inc2 = inc / 2) != self
	inc = inc2
      end
    end
    self + inc
  end

  def prev
    raise FloatDomainError, "No prev value for NaN" if self.nan?
    raise FloatDomainError, "No prev value for infinite" if self.infinite?
    inc = 1.0
    if self - inc == self
      begin
	inc *= 2
      end while self - inc == self
    else
      while self - (inc2 = inc / 2) != self
	inc = inc2
      end
    end
    self - inc
  end

  def decode
    s = [self].pack("G").unpack("B*").first
    sign = s[0,1]
    exp = s[1,11]
    mant = s[12,52]

    sign += " (#{sign.to_i == 0 ? "+" : "-"})"
    case exp
    when /\A1*\z/
      if /\A0*\z/ =~ mant
        exp += " (Inf)"
      else
        if /\A0/ =~ mant
          exp += " (SNaN)"
        else
          exp += " (QNaN)"
        end
      end
    when /\A0*\z/
      if /\A0*\z/ =~ mant
        exp += " (zero)"
      else
        exp += " (denormal p-1022)" # xxx
      end
      mant = "(0.)" + mant
    else
      exp += " (p#{exp.to_i(2) - 1023})"
      mant = "(1.)" + mant
    end

    [sign, exp, mant]
  end

  def Float.encode(sign_, exp_, mant_)
    sign = sign_.gsub(/\(.*\)/, '')
    exp = exp_.gsub(/\(.*\)/, '')
    mant = mant_.gsub(/\(.*\)/, '')

    sign.delete!('^01')
    exp.delete!('^01')
    mant.delete!('^01')

    raise ArgumentError, "invalid sign: #{sign_.inspect}" if sign.length != 1
    raise ArgumentError, "invalid sign: #{exp_.inspect}" if exp.length != 11
    raise ArgumentError, "invalid sign: #{mant_.inspect}" if mant.length != 52

    [(sign+exp+mant)].pack("B*").unpack("G").first;
  end

  def Float.strtod(str)
    # xxx: inf, nan

    unless str =~ /\A([+-])?(\d+)(?:\.(\d+))?(?:e([+-]?\d+))?\z/
      raise ArgumentError, "invalid float format: #{str.inspect}"
    end

    sign = $1 == '-' ? -1 : 1
    int = $2
    frac = $3 || ''
    exp = $4 ? $4.to_i : 0

    int += frac
    exp -= frac.length

    int = int.to_i

    # sign * int * 10**exp

    return sign * 0.0 if int == 0

    exp2 = exp
    exp5 = exp

    # sign * int * 5**exp5 * 2**exp2

    while int[0] == 0
      int >>= 1
      exp2 += 1
    end

    # sign * int * 5**exp5 * 2**exp2

    if 0 <= exp5
      int = int * 5**exp5
      # sign * int * 2**exp2
      bits = int.to_s(2)
      if Float::MANT_DIG < bits.length
        int = bits[0, Float::MANT_DIG].to_i(2)
        exp2 += bits.length - Float::MANT_DIG
        case bits[Float::MANT_DIG..-1]
        when /\A0/
          # round down
        when /\A10*\z/
          # round to even.
          int += 1 if int[0] == 1
        else
          # /\A10*1/
          # round up
          int += 1
        end
      end
      sign * Math.ldexp(int.to_f, exp2) 
    else
      exp5 = -exp5
      # sign * int / 5**exp5 * 2**exp2
      q = 0
      r = int
      d = 5 ** exp5
      # sign * (q + r / d) * 2**exp2
      begin
        while r < d
          q <<= 1
          r <<= 1
          exp2 -= 1
          break if Float::MANT_DIG <= q.to_s(2).length
        end
        q2, r = r.divmod(d)
        # sign * (q + q2 + r / d) * 2**exp2
        q += q2
        # sign * (q + r / d) * 2**exp2
      end while q.to_s(2).length < Float::MANT_DIG
      # sign * (q + r / d) * 2**exp2
      bits = q.to_s(2)
      if Float::MANT_DIG < bits.length
        n = bits.length - Float::MANT_DIG
        d2 <<= n
        q, r2 = q.divmod(d2)
        exp2 += n
        # sign * (q + r2 / d2 + r / (d * d2)) * 2**exp2
        r += d * r2
        d *= d2
        # sign * (q + r / d) * 2**exp2
      end

      if r * 2 < d
        # round down
      elsif r * 2 == d
        # round to even
        q += 1 if q[0] == 1
      else
        # round up
        q += 1
      end
      sign * Math.ldexp(q.to_f, exp2) 
    end
  end
end
