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

end
