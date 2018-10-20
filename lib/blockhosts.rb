#!/usr/bin/env ruby

# file: blockhosts.rb


require 'rxfhelper'

class Host

  @ip = '127.0.0.1'

  @file = case RUBY_PLATFORM
  when /linux|darwin/
    '/etc/hosts'
  when /cygwin|mswin|mingw|bccwin|wince|emx/
    'c:\windows\system32\drivers\etc\hosts'
  else
    '/etc/hosts'
  end

  def self.add(hostname, banlist=nil, 
               hashtag=hostname.sub(/^www./,'').gsub('-','').gsub('.','dot'))

    s = if banlist then

      hashtag = hostname.sub(/^#/,'')
      list, _ = RXFHelper.read(banlist)
      list.lines.map {|hostx| "#{@ip} #{hostx.chomp} ##{hashtag}" }.join("\n")

    else
      "#{@ip} #{hostname} ##{hashtag}"
    end

    open(@file, 'a') { |f| f.puts s } unless File.read(@file).include? hostname
  end

  def self.disable(hashtag)   

    modify() do |line|
      line.gsub(/^#([^#]+##{hashtag.sub(/^#/,'')}[^$]+$)/,'\1')
    end

  end

  def self.enable(hashtag)

    modify() do |line|
      
      if line[0] == '#' then
        line
      else
        line.gsub(/^([^^]+##{hashtag.sub(/^#/,'')}[^$]+$)/,'#\1')
      end
      
    end

  end
  
  def self.block(hashtag)   self.disable(hashtag)  end  
  def self.unblock(hashtag) self.enable(hashtag)   end

  def self.modify()
   
    return unless block_given?

    s = File.read(@file)
    s2 = s.lines.map {|x| yield(x)}.join
    File.write(@file, s2) unless s == s2

  end

end
