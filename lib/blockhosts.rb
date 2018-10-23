#!/usr/bin/env ruby

# file: blockhosts.rb

require 'sps-sub'
require 'rxfhelper'


class Host
  include RXFHelperModule

  @ip = '127.0.0.1'

  @file = case RUBY_PLATFORM
  when /cygwin|mswin|mingw|bccwin|wince|emx/
    'c:\windows\system32\drivers\etc\hosts'
  else # /linux|darwin/
    '/etc/hosts'
  end

  def self.add(hostname, 
               hashtag=hostname.sub(/^www./,'').gsub('-','').gsub('.','dot'),
               banlist: nil, block: false)

    b = block ? '' : '#'
    
    s = if banlist then

      hashtag = hostname.sub(/^#/,'')
      list, _ = RXFHelper.read(banlist)
      list.lines.map {|hostx| "#{b}#{@ip} #{hostx.chomp} ##{hashtag}" }\
          .join("\n")

    else
      "#{b}#{@ip} #{hostname} ##{hashtag}"
    end

    open(@file, 'a') { |f| f.puts s } unless File.read(@file).include? hostname
  end

  def self.disable(hashtag)   

    modify() do |line|
      line.gsub(/^#([^#]+##{hashtag.sub(/^#/,'')}[^$]+)/,'\1')
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
  
  def self.exists?(host)
    s = File.read(@file)
    s.lines.grep(/\s#{host}\s/).any?
  end
  
  def self.export(hashtag, filename=nil)
    
    s = self.view(hashtag)
     
    filename ? FileX.write(filename, s) : s
     
  end
  
  def self.block(hashtag)   self.disable(hashtag)  end  
  def self.unblock(hashtag) self.enable(hashtag)   end

  def self.modify()
   
    return unless block_given?

    s = File.read(@file)
    s2 = s.lines.map {|x| yield(x)}.join
    File.write(@file, s2) unless s == s2

  end

  def self.rm(hashtag)   

    modify() {|line| line =~ /##{hashtag}/ ? '' : line }

  end  
  
  def self.view(hashtag)
    
    File.read(@file).lines.select {|x| x =~ /##{hashtag}/}\
         .map {|x| x[/(?<=#{@ip} )[^ ]+/]}.join("\n")    
    
  end
  
end

class HostsE
  include RXFHelperModule

  def initialize(filename='hostse.txt', sps_host: '127.0.0.1',
        sps_port: '59053', hostname: Socket.gethostname, 
        topic: 'dnslookup/' + hostname, debug: false)

    @sps_host, @sps_port, @topic, @debug = sps_host, sps_port, topic, debug
    @filename = filename
    @entries = FileX.read(filename).lines

  end

  def subscribe(topic=@topic)

    sps = SPSSub.new(host: @sps_host, port: @sps_port)

    sps.subscribe(topic: topic + ' or reload' ) do |host, topic|

      if topic == 'reload' then
        @entries = FileX.read(@filename).lines 
        puts 'reloaded ' if @debug
        next
      end
      
      puts 'host: ' + host.inspect if @debug      
      
      @entries.each do |line|

        pattern, hashtag = line.split(/\s+#/)
        puts 'pattern: ' + pattern.inspect if @debug

        if host =~ /#{pattern.gsub('*','.*')}/ then
          puts 'adding host' if @debug
          Host.add(host, hashtag, block: true) unless Host.exists? host

        end
      end

    end

  end

end
