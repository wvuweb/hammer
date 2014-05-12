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

require './hammer'

class HammerServlet < WEBrick::HTTPServlet::AbstractServlet
  include Hammer
end

doc_root = ARGV.shift || Dir::pwd

puts " "
puts "                                \`.         ".colorize(:light_magenta)
puts "      .--------------.___________) \        ".colorize(:light_magenta)
puts "      |//////////////|___________[ ]        ".colorize(:light_magenta)
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
  :Port => 2000,
  :DocumentRoot => doc_root,
  :DirectoryIndex => []
)

httpd.mount("/", HammerServlet, doc_root, true)

trap(:INT){ httpd.shutdown }
httpd.start
