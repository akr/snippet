class Binding
  def define(name, value)
    eval("#{name} = nil; lambda {|#{name}|}", self).call(value)
  end
end
