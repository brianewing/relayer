module Relayer
  class IRCEvents
    def initialize(protocol, client)
      @protocol = protocol
      @client = client
      
      @handlers = {
        :ping => [],
        :connected => [],
        :channel_msg => [],
        :ctcp => []
      }
    end
    
    def method_missing(event, *args, &handler)
      raise ArgumentError if handler.nil?
      
      if @handlers.has_key? event
        @handlers[event].push handler
      else
        raise NoMethodError
      end
    end
    
    def dispatch(event, args)
      @handlers[event].each do |handler|
        handler.call(@protocol, args)
      end
    end
  end
end
