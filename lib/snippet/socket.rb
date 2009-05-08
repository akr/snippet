require 'socket'

class Socket
  TCP_ESTABLISHED = 1
  TCP_SYN_SENT = 2
  TCP_SYN_RECV = 3
  TCP_FIN_WAIT1 = 4
  TCP_FIN_WAIT2 = 5
  TCP_TIME_WAIT = 6
  TCP_CLOSE = 7
  TCP_CLOSE_WAIT = 8
  TCP_LAST_ACK = 9
  TCP_LISTEN = 10
  TCP_CLOSING = 11 # now a valid state

  TCP_MAX_STATES = 12 # Leave at the end!

  #TCP_INFO = 11
end

