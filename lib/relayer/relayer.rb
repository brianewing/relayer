require "relayer/client"
require "relayer/socket"
require "relayer/version"

module Relayer
  def Relayer::start!(bots)
    if bots.respond_to? :each
      bots.each do |bot|
        bot.start
      end
    else
      bots.start
    end
    
    unless IRCSocketSelector.started?
      IRCSocketSelector.start!
    end
  end
end