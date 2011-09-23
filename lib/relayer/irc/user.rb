module Relayer::IRC
  class User
    IRC_HOSTMASK_REGEX = /^([^\!@]+)(\!([^\!@]+))(@(.+))$/
    
    attr_accessor :nick, :ident, :hostname, :hostmask
    
    def self.is_user?(hostmask)
      not IRC_HOSTMASK_REGEX.match(hostmask).nil?
    end
    
    def to_s
      @nick
    end
    
    def self.parse_hostmask(hostmask)
      match = IRC_HOSTMASK_REGEX.match hostmask
      return if match.nil?
      
      raw, nick, ident_tmp, ident, hostname_tmp, hostname = match.to_a
      return :nick => nick, :ident => ident, :hostname => hostname
    end
    
    def parse_hostmask!
      parts = User.parse_hostmask @hostmask
      
      @nick = parts[:nick]
      @ident = parts[:ident]
      @hostname = parts[:hostname]
    end
    
    def initialize(hostmask)
      @hostmask = hostmask
      parse_hostmask!
    end
  end
end