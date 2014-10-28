# encoding: utf-8

require 'rubygems'
require "bundler/setup"

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

options = OpenStruct.new
options.directory = (Pathname.new(Dir.pwd).parent.parent + "cleanslate_themes").to_s
options.port = 2000

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
  
  o.parse!(ARGV)
end


g = Git.open("../")
ref = g.log.first {|l| l.sha }
remote = g.lib.send(:command, 'ls-remote').split(/\n/)[1].split(/\t/)[0]

if ref.to_s != remote.to_s
  puts " "
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
  puts "!!!".colorize(:red)+" WARNING YOU ARE BEHIND ON HAMMER VERSIONS".colorize(:light_cyan)+" !!!".colorize(:red)
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
  puts " "
  puts "Repository is currently at ref: ".colorize(:light_white)+(ref.to_s+" ").colorize(:light_magenta)
  puts "Remote is currently at ref: ".colorize(:light_white)+(remote.to_s+" ").colorize(:light_magenta)
  puts "Learn to upgrade at: ".colorize(:light_white)+"https://github.com/wvuweb/hammer/wiki/Upgrade".colorize(:light_cyan)
  puts " "
  puts "Do you want to continue".colorize(:light_white)+" (Y/n) ?".colorize(:light_green)
  if Gem.win_platform?
    input = STDIN.gets.chomp
  else 
    input = gets.chomp
  end
  if input == 'n' then
   exit
  end
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
  :DirectoryIndex => []
)

httpd.mount("/", HammerServlet, doc_root, true)

trap(:INT){ httpd.shutdown }
httpd.start
