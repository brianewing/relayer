require "relayer/irc/user"
require "relayer/irc/channel"

module Relayer
  class IRCProtocolException < Exception; end
  
  class IRCProtocol
    IRC_LINE_REGEX = /^(:([^ ]+) )?([A-Z0-9]+) ([^:]+)? ?(:(.*))?$/
    
    def initialize(client)
      @client = client
      @registration_commands = []
    end
    
    def dispatch(event, args = {})
      @client.events.dispatch(event, args)
    end
    
    def process_line(line)
      match = IRC_LINE_REGEX.match(line)
      raise IRCProtocolException if match.nil?
      
      raw, actor_tmp, actor, command, args, ext_tmp, extended_arg = match.to_a
      
      if Relayer::IRC::User.is_user? actor
        actor = @client.user(actor)
      else
        actor = nil #todo: implement server actors
      end
      
      args = args.split unless args.nil?
      command = command.downcase.to_sym unless command.nil?
      
      if actor.nil?
        # match server-only commands like 'PING'
        case command
          when :ping
            dispatch :ping, :token => extended_arg
        end
        
        if ("001".."004").include? command.to_s
          @registration_commands.push command.to_s
          
          dispatch :connected if registered?
        end
      else
        case command
          when :privmsg
            to = args[0]
            
            message = extended_arg
            
            is_ctcp = message.start_with?("\001") and message.end_with?("\001")
            message = message[1..-2] if is_ctcp
            
            if is_ctcp
              query_args = message.split
              query = query_args.shift.downcase.to_sym
              
              dispatch :ctcp, :actor => actor, :channel => @client.channel(to), :query => query, :args => query_args
            elsif IRC::Channel.is_channel?(to)
              dispatch :channel_msg, :actor => actor, :channel => @client.channel(to), :message => extended_arg
            elsif to.downcase == @nick.downcase
              dispatch :private_msg, :actor => actor, :message => extended_arg
            end
        end
      end
    end
    
    def registered?
      (("001".."004").to_a - @registration_commands).empty?
    end
    
    def send_command(command, *args)
      if args.last.include?(' ')
        arg = args.pop
        arg.insert(0, ':')
        args.push(arg)
      end
      
      @client.send_raw "#{command.to_s.upcase} #{args.join ' '}"
    end
    
    def pong(token = false)
      send_command :pong, token
    end
    
    def ctcp(label, to)
      extended_arg = "\001#{label.to_s.upcase}\001"
      
      send_command :privmsg, to, extended_arg
    end
    
    def ctcp_reply(label, to, data)
      data = " #{data}" if data
      extended_arg = "\001#{label.to_s.upcase}#{data}\001"
      
      send_command :notice, to, extended_arg
    end
    
    def message(channel, message)
      send_command :privmsg, channel, message
    end
    
    def nick(nickname)
      send_command :nick, nickname
    end
    
    def join(channel)
      channel = "\##{channel}" unless channel[0] == '#'
      send_command :join, channel
    end
    
    def user(ident, real_name)
      send_command :user, ident, '0', '*', real_name
    end
  end
end