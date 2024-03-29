[Relayer](http://github.com/brianewing/relayer) is a dead simple, high-performance, event-driven IRC library written in Ruby.
-----------------------------------------------------------------------------------------------------------------------------

It uses IO#select to achieve asynchronous IO, and has been tested to handle many hundreds of concurrent IRC connections from one instance.

Sample usage:

```Ruby
echo = Relayer::IRCClient.new(:hostname => 'irc.esper.net', :nick => 'EchoBot', :channels => ['#echo'])

echo.events.channel_msg do |irc, event|
  irc.message event[:channel], event[:message]
end

Relayer::start! echo
```