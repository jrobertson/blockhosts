#!/usr/bin/env ruby

# file: blockhosts.rb


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

  def self.add(hostname)
    s = "#{@ip} #{hostname}"
    open(@file, 'a') { |f| f.puts s } unless File.read(@file).include? hostname
  end

  def self.disable(hostname)
    modify() {|s| s.sub(/^#(#{@ip}\s+#{hostname}[^$]+)$/,'\1')}
  end

  def self.enable(hostname)
    modify() {|s| s.sub(/^(#{@ip}\s+#{hostname}[^$]+)$/,'#\1')}
  end

  def self.modify()
   
    return unless block_given?

    s = File.read(@file)
    s2 = yield(s)
    File.write(@file, s2) unless s == s2

  end

end
