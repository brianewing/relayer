module Relayer::IRC
  class Channel
    attr_accessor :users
    
    def self.is_channel?(channel)
      channel[0] == '#'
    end
    
    def to_s
      @channel
    end
    
    def initialize(channel)
      @channel = channel
      @users = []
    end
  end
end