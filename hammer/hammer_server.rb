# encoding: utf-8

require 'rubygems'
require 'bundler/setup'
require 'rbconfig'

require 'webrick'
require 'radius'
require 'pry'
require 'chronic'
require 'htmlentities'
require 'nokogiri'
require 'sanitize'
require 'colorize'

require 'optparse'
require 'ostruct'
require 'git'

require './hammer'

class HammerServlet < WEBrick::HTTPServlet::AbstractServlet
  include Hammer
end

def os
  @os ||= (
    host_os = RbConfig::CONFIG['host_os']
    case host_os
    when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
      :windows
    when /darwin|mac os/
      :macosx
    when /linux/
      :linux
    when /solaris|bsd/
      :unix
    else
      raise Error::WebDriverError, "unknown os: #{host_os.inspect}"
    end
  )
end

options = OpenStruct.new
options.directory = (Pathname.new(Dir.pwd).parent.parent + "cleanslate_themes").to_s
options.port = 2000
options.daemon = WEBrick::SimpleServer

OptionParser.new do |o|
  o.on('-d', '--directory directory', String, 'Directory to start hammer in') do |d|
    options.directory = d
  end

  o.on('-q', '--quick directory', String, 'Quick access a default directory') do |q|
    options.directory = (Pathname.new(Dir.pwd).parent.parent + "cleanslate_themes/#{q}").to_s
  end

  o.on('-p', '--port port', Integer, 'Port to start hammer server on') do |p|
    options.port = p
  end

  o.on('-da', '--daemon daemon', Integer, 'If the server should run Daemonized') do |da|
    options.daemon = da == 1 ?  WEBrick::Daemon : WEBrick::SimpleServer
  end

  o.parse!(ARGV)
end


g = Git.open("../")
ref = g.log.first {|l| l.sha }
remote = g.lib.send(:command, 'ls-remote').split(/\n/)[1].split(/\t/)[0]

if ref.to_s == remote.to_s
  update_url = "https://github.com/wvuweb/hammer/wiki/Update"
  puts " "
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
  puts "!!!".colorize(:red)+" WARNING YOU ARE BEHIND ON HAMMER VERSIONS".colorize(:light_cyan)+" !!!".colorize(:red)
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
  puts " "
  puts "Repository is currently at ref: ".colorize(:light_white)+(ref.to_s+" ").colorize(:light_magenta)
  puts "Remote is currently at ref: ".colorize(:light_white)+(remote.to_s+" ").colorize(:light_magenta)
  # puts "Learn how to update Hammer at: ".colorize(:light_white)+update_url.colorize(:light_cyan)
  puts " "
  puts " "
  puts "Update Hammer by using using the following command: ".colorize(:light_white)
  puts " "
  puts "vagrant hammer update".colorize(:light_green)
  puts " "
  puts "Hammer will automatically restart after updating itself".colorize(:light_white)
  puts " "
  puts " "
end

doc_root = options.directory

puts "Dropping the Hammer on #{doc_root}".colorize(:red)

puts " "
puts "                                \\`.         ".colorize(:light_magenta)
puts "      .--------------.___________) \\        ".colorize(:light_magenta)
puts "      |//// WVU /////|___________[ ]        ".colorize(:light_magenta)
puts "      `--------------'           ) (        ".colorize(:light_magenta)
puts "                                 '-'        ".colorize(:light_magenta)
puts "############################################".colorize(:yellow)
puts "#     HAMMER - Clean Slate Mock Server     #".colorize(:yellow)
puts "############################################".colorize(:yellow)
puts " "
puts " Starting in #{doc_root}... ".black.on_green
puts " "
puts " "

httpd = WEBrick::HTTPServer.new(
  :Port => options.port,
  :DocumentRoot => doc_root,
  :ServerType => options.daemon,
  :DirectoryIndex => []
)

httpd.mount("/", HammerServlet, doc_root, true)

trap(:INT){ httpd.shutdown }
httpd.start
