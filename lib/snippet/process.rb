class Process::Status
  def inspect
    coredump = coredump? ? " (core dumped)" : ""
    if exited?
      "#<#{self.class}: #{self.pid} exited: #{exitstatus}#{coredump}>"
    elsif stopped?
      "#<#{self.class}: #{self.pid} stopped: #{Signal.list.invert[stopsig]}#{coredump}>"
    elsif signaled?
      "#<#{self.class}: signaled: #{Signal.list.invert[termsig]}#{coredump}>"
    else
      "#<#{self.class}: #{self.pid} 0x#{to_i.to_s(16)}#{coredump}>"
    end
  end
end

