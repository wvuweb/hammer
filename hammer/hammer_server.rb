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
