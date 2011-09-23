require "relayer/event/event"

module Relayer::Event
  class Message < Event
    attr_accessor :sender, :message, :channel
    
    def initialize(sender, message, channel)
      @sender = sender
      @message = message
      @channel = channel
    end
  end
end