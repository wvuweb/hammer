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

  o.on('-x', '--virtualmachine virtualmachine', TrueClass, 'If the server is running as a VM') do |vm|
    options.virtualmachine = x
  end

  o.parse!(ARGV)
end


g = Git.open("../")
begin
  branch = g.lib.send(:command, "symbolic-ref --short HEAD")
  ref = g.lib.send(:command, "rev-parse #{branch}")
  remote = g.lib.send(:command, "rev-parse origin/#{branch}")

  if ref.to_s != remote.to_s
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
rescue
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
  puts "!!!".colorize(:red)+" COULD NOT CHECK HAMMER REPOSITORY FOR UPDATES".colorize(:light_cyan)+" !!!".colorize(:red)
  puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
end

if options.directory
  doc_root = options.directory
else
  doc_root = "../cleanslate_themes"
end

# Check for code directory
if options.vm
  code_dir = File.directory?('srv/cleanslate_themes/code')
  code = Git.open("srv/cleanslate_themes/code")
else
  code_dir = File.directory?(doc_root+"/code")
  code = Git.open(doc_root+"/code")
end

if code_dir
  begin
    code_ref = code.lib.send(:command, "rev-parse master")
    code_remote = code.lib.send(:command, "rev-parse origin/master")

    if code_ref.to_s != code_remote.to_s
      puts " "
      puts "WARNING:".colorize(:red)
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:light_cyan)
      puts "Your ".colorize(:red)+"Code Git Repository".colorize(:light_white)+" is out of date, please update it ".colorize(:red)
      puts "by changing directory into ".colorize(:red)+doc_root+"/code".colorize(:light_green)
      puts "then running ".colorize(:red)+"git pull".colorize(:light_green)
      puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:light_cyan)
      puts " "
    end
  rescue
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
    puts "!!!".colorize(:red)+" COULD NOT CHECK CODE REPOSITORY FOR UPDATES".colorize(:light_cyan)+" !!!".colorize(:red)
    puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!".colorize(:red)
  end

else
  puts " "
  puts "Code directory not found at #{doc_root}/code.  If you want to use the shared repository".colorize(:red)
  puts "please ".colorize(:red)+"git clone http://stash.development.wvu.edu/scm/cst/code.git".colorize(:light_green)
  puts "into your cleanslate_themes directory".colorize(:red)
  puts " "
end

puts " "
puts "                                    \\`.         ".colorize(:light_magenta)
puts "          .--------------.___________) \\        ".colorize(:light_magenta)
puts "          |//// WVU /////|___________[ ]        ".colorize(:light_magenta)
puts "          `--------------'           ) (        ".colorize(:light_magenta)
puts "                                     '-'        ".colorize(:light_magenta)
puts "    ############################################".colorize(:yellow)
puts "    #     HAMMER - Clean Slate Mock Server     #".colorize(:yellow)
puts "    ############################################".colorize(:yellow)
puts " "
puts "    Starting in #{doc_root}...     ".black.on_green
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
