require './lib/relayer'

echo = Relayer::IRCClient.new(:hostname => 'irc.alphachat.net', :nick => 'EchoBot', :channels => ['#lobby'])

echo.events.channel_msg do |irc, event|
  msg = event[:message].sub('!say ', '')
  irc.message(event[:channel], msg) unless msg.blank?
end

Relayer::start! echo