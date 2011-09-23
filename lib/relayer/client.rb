require "relayer/events"
require "relayer/protocol"
require "relayer/version"

module Relayer
  class IRCClient
    attr_accessor :events
    attr_accessor :nick
    attr_accessor :protocol
    
    def initialize(options = {})
      @ssl = options[:ssl]
      
      @hostname = options[:hostname]
      @port = options[:port]
      
      @ping_reply = options[:ping_reply]
      @version_reply = options[:version_reply]
      
      @version_string = options[:version_string]
      
      @nick = options[:nick]
      @nick_pass = options[:pass]
      @ident = options[:ident]
      @real_name = options[:real_name]
      
      @first_channels = options[:channels] || []
      default_options!
      
      @users = {}
      @channels = {}
      
      @protocol = IRCProtocol.new(self)
      @events = IRCEvents.new(@protocol, self)
      
      default_handlers!
    end
    
    def version_string
      @version_string || "Relayer IRC Library v#{Relayer::VERSION}"
    end
    
    def register
      @protocol.user(@ident, @real_name)
      @protocol.nick(@nick)
    end
    
    def default_handlers!
      @events.ping do |irc, event|
        @protocol.pong event[:token]
      end
      
      @events.connected do
        unless @nick_pass.nil?
          @protocol.message('NickServ', "identify #{@nick_pass}")
        end

        @first_channels.each do |channel|
          @protocol.join(channel)
        end
      end
      
      @events.ctcp do |irc, event|
        @protocol.ctcp_reply :version, event[:actor], version_string if event[:query] == :version
      end
    end
    
    def default_options!
      if @ssl.nil?
        @ssl = false
      end
      
      unless @port
        @port = 6697 if @ssl
        @port ||= 6667
      end
      
      @nick ||= "Relayer"
      @ident ||= "relayer"
      @real_name ||= "Relayer"
      
      @hostname ||= 'irc.freenode.net'
    end
    
    def start
      @socket = IRCSocket.new(self, @hostname, @port, @ssl)
      register
    end
    
    def readable
      @socket.read
    end
    
    def writable
      @socket.write
    end
    
    def process_raw(line)
      @protocol.process_line(line)
    end
    
    def send_raw(line)
      @socket.send line
    end
    
    def user(hostmask)
      parts = IRC::User.parse_hostmask(hostmask)
      
      nickname = parts[:nick].downcase
      @users[nickname] ||= IRC::User.new(hostmask) if IRC::User.is_user?(hostmask)
    end
    
    def channel(channel)
      channel = channel.downcase
      @channels[channel] ||= IRC::Channel.new(channel) if IRC::Channel.is_channel?(channel)
    end
  end
end