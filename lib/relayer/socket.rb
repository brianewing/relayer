require "socket"

module Relayer
  class IRCSocket
    def initialize(client, host, port)
      @client = client
      @socket = TCPSocket.open(host, port)
      
      register_selector
    end
    
    def register_selector
      IRCSocketSelector.add_irc_socket(@socket, @client)
    end
    
    def read
      data = @socket.gets
      data = data.sub "\r", ''
      
      lines = data.split "\r\n"
      
      lines.each do |line|
        @client.process_raw line
      end
    end
    
    def send(line)
      @socket.puts line
    end
    
    def close
      @socket.close
    end
  end
  
  class IRCSocketSelector
    @@sockets = {}
    @@started = false
    
    def self.instance
      @@instance ||= IRCSocketSelector.new
    end
    
    def self.add_irc_socket(socket, client)
      @@sockets[socket] = client
    end
    
    def self.select
      sockets = @@sockets.keys
      
      readable, writable, exceptioned = IO.select(sockets, nil, nil)
      
      readable.each do |socket|
        client = @@sockets[socket]
        client.readable
      end
    end
    
    def self.started?
      @@started
    end
    
    def self.start!
      return if @@sockets.empty?
      
      @@started = true
      while true
        IRCSocketSelector.select
      end
    end
  end
end